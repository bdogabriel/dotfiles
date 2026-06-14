#!/usr/bin/env python3
import json
import os
import sys


def clamp(value, lo, hi):
    return max(lo, min(value, hi))


def load_json(path):
    with open(path) as f:
        return json.load(f)


def write_json(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


def aggregate(baseline_data, eval_data):
    baseline_runs = {r["use_case_id"]: r for r in baseline_data["runs"]}
    eval_runs = {r["use_case_id"]: r for r in eval_data["runs"]}

    triggered_ids = {
        r["use_case_id"] for r in eval_data["runs"] if r["skill_triggered"]
    }
    triggered_count = len(triggered_ids)
    total_runs = len(eval_data["runs"])
    skip_effectiveness = triggered_count == 0

    all_eval = eval_data["runs"]
    all_base = baseline_data["runs"]

    if not skip_effectiveness:
        with_passed = sum(
            eval_runs[uid]["assertions_passed"] for uid in triggered_ids
        )
        with_total = sum(
            eval_runs[uid]["assertions_total"] for uid in triggered_ids
        )
        without_passed = sum(
            baseline_runs[uid]["assertions_passed"] for uid in triggered_ids
        )
        without_total = sum(
            baseline_runs[uid]["assertions_total"] for uid in triggered_ids
        )

        pass_rate_with = with_passed / max(with_total, 1)
        pass_rate_without = without_passed / max(without_total, 1)
    else:
        pass_rate_with = 0.0
        pass_rate_without = 0.0

    delta = pass_rate_with - pass_rate_without

    tokens_with = sum(r["tokens"] for r in all_eval) / max(len(all_eval), 1)
    tokens_without = sum(r["tokens"] for r in all_base) / max(len(all_base), 1)
    duration_with = sum(r["duration_ms"] for r in all_eval) / max(len(all_eval), 1)
    duration_without = sum(r["duration_ms"] for r in all_base) / max(len(all_base), 1)

    discriminating = 0
    total_assertions = 0
    for eval_run in eval_data["runs"]:
        uc_id = eval_run["use_case_id"]
        base_run = baseline_runs.get(uc_id)
        if base_run is None:
            continue
        eval_assertions = eval_run.get("assertions", [])
        base_assertions = base_run.get("assertions", [])
        base_by_text = {a["text"]: a for a in base_assertions}
        for ea in eval_assertions:
            total_assertions += 1
            ba = base_by_text.get(ea["text"])
            if ba is not None and ea["passed"] != ba["passed"]:
                discriminating += 1

    return {
        "skill_name": eval_data["skill_name"],
        "model_version": eval_data["model_version"],
        "has_dangerous_use_cases": any(
            r.get("is_safe") is False for r in eval_data["runs"]
        ),
        "skip_effectiveness": skip_effectiveness,
        "triggered": triggered_count,
        "total": total_runs,
        "pass_rate_with": pass_rate_with,
        "pass_rate_without": pass_rate_without,
        "delta": delta,
        "tokens_with": tokens_with,
        "tokens_without": tokens_without,
        "duration_with": duration_with,
        "duration_without": duration_without,
        "discriminating": discriminating,
        "total_assertions": total_assertions,
    }


def compute_effectiveness(delta):
    return clamp(delta, 0.0, 1.0)


def compute_trigger_accuracy(triggered, total):
    if total == 0:
        return 0.0
    return triggered / total


def compute_efficiency(delta, tokens_with, tokens_without, duration_with, duration_without):
    if tokens_without == 0:
        tokens_without = 1
    if duration_without == 0:
        duration_without = 1
    token_ratio = tokens_with / tokens_without
    if token_ratio == 0:
        token_ratio = 1.0
    duration_ratio = duration_with / duration_without
    if duration_ratio == 0:
        duration_ratio = 1.0
    cost_ratio = (token_ratio + duration_ratio) / 2
    value_per_cost = max(0, delta) / cost_ratio
    return clamp(value_per_cost, 0.0, 1.0)


def compute_discrimination(discriminating, total):
    if total == 0:
        return 0.0
    return discriminating / total


VERDICT_THRESHOLDS = {
    "effectiveness": [(0.50, "acceptable"), (0.20, "low"), (float("-inf"), "critical")],
    "trigger_accuracy": [(0.80, "acceptable"), (0.50, "low"), (float("-inf"), "critical")],
    "efficiency": [(0.40, "acceptable"), (0.20, "low"), (float("-inf"), "critical")],
    "discrimination": [(0.50, "acceptable"), (0.30, "low"), (float("-inf"), "critical")],
}


def compute_verdict(axis, score):
    for threshold, label in VERDICT_THRESHOLDS[axis]:
        if score >= threshold:
            return label
    return "critical"


def build_output(agg):
    skip = agg["skip_effectiveness"]

    if skip:
        weights = {
            "trigger_accuracy": 3.0 / 7.0,
            "efficiency": 2.0 / 7.0,
            "discrimination": 2.0 / 7.0,
        }
    else:
        weights = {
            "effectiveness": 0.30,
            "trigger_accuracy": 0.30,
            "efficiency": 0.20,
            "discrimination": 0.20,
        }

    scores = {}
    if not skip:
        scores["effectiveness"] = compute_effectiveness(agg["delta"])
    scores["trigger_accuracy"] = compute_trigger_accuracy(
        agg["triggered"], agg["total"]
    )
    scores["efficiency"] = compute_efficiency(
        agg["delta"], agg["tokens_with"], agg["tokens_without"],
        agg["duration_with"], agg["duration_without"],
    )
    scores["discrimination"] = compute_discrimination(
        agg["discriminating"], agg["total_assertions"]
    )

    axes = {}
    for axis in weights:
        axes[axis] = {
            "score": round(scores[axis], 2),
            "weight": round(weights[axis], 3),
            "weighted": round(scores[axis] * weights[axis], 3),
            "verdict": compute_verdict(axis, scores[axis]),
        }

    if scores["discrimination"] == 0.0:
        for axis in axes:
            axes[axis]["score"] = "N/A"
            axes[axis]["weighted"] = 0
            axes[axis]["verdict"] = "N/A"
        return {
            "skill_name": agg["skill_name"],
            "model_version": agg["model_version"],
            "score": "VOID",
            "has_dangerous_use_cases": agg["has_dangerous_use_cases"],
            "axes": axes,
            "reason": "no discriminating assertions — every assertion passed or failed identically in both configurations",
        }, True

    final_score = sum(scores[axis] * weights[axis] for axis in weights)

    duration_delta_s = round((agg["duration_with"] - agg["duration_without"]) / 1000, 1)

    warnings = []
    if skip:
        warnings.append(
            "effectiveness skipped: no use cases triggered the skill in eval runs"
        )
    elif agg["triggered"] < 2:
        warnings.append(
            "low confidence: fewer than 2 use cases triggered the skill"
        )
    if not skip and agg["delta"] < 0:
        warnings.append(
            "negative effectiveness delta: the skill made outcomes worse than having no skill at all"
        )
    if agg["has_dangerous_use_cases"]:
        warnings.append(
            "unsafe use cases were evaluated in plan mode; effectiveness reflects decision guidance rather than execution outcomes"
        )

    priorities = []
    for axis in weights:
        s = scores[axis]
        v = compute_verdict(axis, s)
        if v != "acceptable":
            priorities.append({
                "axis": axis,
                "score": round(s, 2),
                "weight": round(weights[axis], 3),
                "verdict": v,
                "priority": round((1 - s) * weights[axis], 3),
            })
    priorities.sort(key=lambda r: r["priority"], reverse=True)

    output = {
        "skill_name": agg["skill_name"],
        "model_version": agg["model_version"],
        "score": round(final_score, 2),
        "has_dangerous_use_cases": agg["has_dangerous_use_cases"],
        "axes": axes,
        "skipped_axes": ["effectiveness"] if skip else [],
        "duration": {
            "with_skill_s": round(agg["duration_with"] / 1000, 1),
            "without_skill_s": round(agg["duration_without"] / 1000, 1),
            "delta_s": duration_delta_s,
            "delta_label": "saved" if duration_delta_s < 0 else ("lost" if duration_delta_s > 0 else "unchanged"),
        },
        "warnings": warnings,
        "priorities": priorities,
    }

    return output, False


def main():
    if len(sys.argv) < 3 and not (
        len(sys.argv) == 2 and os.path.isdir(sys.argv[1])
    ):
        print(
            "Usage: compute_score.py <baseline_results.json> <eval_results.json> [--verbose]\n"
            "       compute_score.py <.skill-score-dir> [--verbose]",
            file=sys.stderr,
        )
        sys.exit(1)

    verbose = "--verbose" in sys.argv
    args = [a for a in sys.argv[1:] if a != "--verbose"]

    if len(args) == 1 and os.path.isdir(args[0]):
        output_dir = os.path.abspath(args[0])
        baseline_path = os.path.join(output_dir, "baseline_results.json")
        eval_path = os.path.join(output_dir, "eval_results.json")
    else:
        baseline_path = os.path.abspath(args[0])
        eval_path = os.path.abspath(args[1])
        baseline_dir = os.path.dirname(baseline_path)
        eval_dir = os.path.dirname(eval_path)
        if baseline_dir == eval_dir:
            output_dir = baseline_dir
        else:
            output_dir = os.getcwd()

    baseline_data = load_json(baseline_path)
    eval_data = load_json(eval_path)

    agg = aggregate(baseline_data, eval_data)

    write_json(os.path.join(output_dir, "eval_aggregate.json"), {
        "skill_name": agg["skill_name"],
        "model_version": agg["model_version"],
        "has_dangerous_use_cases": agg["has_dangerous_use_cases"],
        "axes": {
            "effectiveness": {
                "pass_rate_with_skill": agg["pass_rate_with"],
                "pass_rate_without_skill": agg["pass_rate_without"],
            } if not agg["skip_effectiveness"] else None,
            "trigger_accuracy": {
                "triggered": agg["triggered"],
                "total": agg["total"],
            },
            "efficiency": {
                "pass_rate_delta": agg["delta"],
                "tokens_with_skill": agg["tokens_with"],
                "tokens_without_skill": agg["tokens_without"],
                "duration_ms_with_skill": agg["duration_with"],
                "duration_ms_without_skill": agg["duration_without"],
            },
            "discrimination": {
                "discriminating_assertions": agg["discriminating"],
                "total_assertions": agg["total_assertions"],
            },
        },
    })

    output, is_void = build_output(agg)

    write_json(os.path.join(output_dir, "results.json"), output)

    if is_void:
        print(
            "VOID: no discriminating assertions — the evaluation measures nothing",
            file=sys.stderr,
        )
        if verbose:
            print(json.dumps(output, indent=2))
        sys.exit(2)

    if verbose:
        print(json.dumps(output, indent=2))
    else:
        print(round(output["score"], 2))


if __name__ == "__main__":
    main()
