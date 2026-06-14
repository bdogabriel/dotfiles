#!/usr/bin/env python3
"""
Deterministic skill-lint checks. Reads a skill directory, parses SKILL.md
frontmatter, and emits JSON with pass/fail results to stdout.

Usage: python validate.py <path/to/skill-directory>
"""

import json
import os
import re
import sys


RESERVED_NAMES = {"anthropic", "claude"}
MAX_NAME_LEN = 64
MAX_DESCRIPTION_LEN = 1024
MAX_COMPATIBILITY_LEN = 500
MAX_SKILL_MD_LINES = 500
VALID_NAME_RE = re.compile(r"^[a-z][a-z0-9]*(-[a-z0-9]+)*$")


def load_skill_md(path):
    file_path = os.path.join(path, "SKILL.md")
    if not os.path.isfile(file_path):
        return None, None, None, None, None
    with open(file_path) as f:
        raw = f.read()
    lines = raw.split("\n")
    if not raw.startswith("---"):
        return raw, lines, None, None, None
    parts = raw.split("---", 2)
    if len(parts) < 3:
        return raw, lines, None, None, None
    frontmatter_str = parts[1]
    body = parts[2]
    try:
        import yaml
        metadata = yaml.safe_load(frontmatter_str)
    except Exception:
        metadata = None
    return raw, lines, metadata, body, frontmatter_str


def check_yaml_valid(metadata, frontmatter_str):
    if metadata is None:
        return False
    return True


def check_field_present(metadata, field):
    if metadata is None:
        return False
    return bool(metadata.get(field))


def check_name_matches_dir(metadata, skill_dir):
    if metadata is None:
        return False
    expected = os.path.basename(os.path.normpath(skill_dir))
    return metadata.get("name") == expected


def check_name_length(metadata):
    if metadata is None:
        return False
    name = metadata.get("name", "")
    return len(name) <= MAX_NAME_LEN


def check_name_regex(metadata):
    if metadata is None:
        return False
    name = metadata.get("name", "")
    return bool(VALID_NAME_RE.match(name))


def check_no_reserved_name(metadata):
    if metadata is None:
        return False
    name = metadata.get("name", "")
    name_lower = name.lower()
    for reserved in RESERVED_NAMES:
        if reserved in name_lower:
            return False
    return True


def check_description_non_empty(metadata):
    if metadata is None:
        return False
    desc = metadata.get("description", "")
    return bool(desc.strip())


def check_description_length(metadata):
    if metadata is None:
        return False
    desc = metadata.get("description", "")
    return len(desc) <= MAX_DESCRIPTION_LEN


def check_no_xml_tags(text):
    if text is None:
        return True
    return not bool(re.search(r"<[a-zA-Z/!?][^>]*>", text))


def check_xml_name(metadata):
    if metadata is None:
        return False
    return check_no_xml_tags(metadata.get("name"))


def check_xml_description(metadata):
    if metadata is None:
        return False
    return check_no_xml_tags(metadata.get("description"))


def check_compatibility_length(metadata):
    if metadata is None:
        return False
    compat = metadata.get("compatibility")
    if compat is None:
        return True
    return len(str(compat)) <= MAX_COMPATIBILITY_LEN


def check_skill_md_exists(skill_dir):
    return os.path.isfile(os.path.join(skill_dir, "SKILL.md"))


def check_skill_md_line_count(raw_lines):
    if raw_lines is None:
        return False
    return len(raw_lines) <= MAX_SKILL_MD_LINES


def check_no_windows_paths(raw_text):
    if raw_text is None:
        return True
    return "\\\\" not in raw_text


def check_reference_depth(skill_dir):
    skill_md_path = os.path.join(skill_dir, "SKILL.md")
    if not os.path.isfile(skill_md_path):
        return False
    with open(skill_md_path) as f:
        skill_md = f.read()
    direct_refs = set(re.findall(r"\[.*?\]\(([^)]+)\)", skill_md))
    for ref in direct_refs:
        ref_path = os.path.normpath(os.path.join(skill_dir, ref))
        if not os.path.isfile(ref_path):
            continue
        with open(ref_path) as f:
            ref_content = f.read()
        nested = re.findall(r"\[.*?\]\(([^)]+)\)", ref_content)
        for n in nested:
            nested_path = os.path.normpath(os.path.join(os.path.dirname(ref_path), n))
            if os.path.isfile(nested_path):
                return False
    return True


def check_license_format(metadata):
    if metadata is None:
        return False
    lic = metadata.get("license")
    if lic is None:
        return True
    if not isinstance(lic, str):
        return False
    return len(lic) <= 200


def check_description_not_placeholder(metadata):
    if metadata is None:
        return False
    desc = (metadata.get("description") or "").strip().lower()
    placeholders = [
        "todo", "add description", "describe", "tbd",
        "what this skill does", "description here", "your description",
    ]
    for p in placeholders:
        if desc == p:
            return False
    return True


def check_description_no_unquoted_colons(frontmatter_str):
    if frontmatter_str is None:
        return False
    for line in frontmatter_str.split("\n"):
        stripped = line.lstrip()
        if not stripped.startswith("description:"):
            continue
        value = stripped[len("description:"):].lstrip()
        if value.startswith('"') or value.startswith("'"):
            return True
        if ": " in value:
            return False
        return True
    return True


CHECKS = [
    ("spec-yaml-valid", "YAML frontmatter is valid"),
    ("spec-name-present", "name field present"),
    ("spec-description-present", "description field present"),
    ("spec-name-matches-dir", "name matches parent directory"),
    ("spec-name-length", "name length <= 64"),
    ("spec-name-regex", "name matches regex (lowercase, hyphens, no consecutive hyphens)"),
    ("spec-no-reserved-name", "no reserved words in name (anthropic, claude)"),
    ("spec-description-non-empty", "description is not empty"),
    ("spec-description-length", "description <= 1024 chars"),
    ("spec-no-xml-name", "no XML tags in name"),
    ("spec-no-xml-description", "no XML tags in description"),
    ("spec-compatibility-length", "compatibility <= 500 chars"),
    ("spec-license-format", "license field format valid"),
    ("spec-description-not-placeholder", "description is not a placeholder"),
    ("spec-description-no-unquoted-colons", "description value is quoted if it contains colons"),
    ("struct-skill-md-exists", "SKILL.md exists in directory"),
    ("struct-skill-md-lines", "SKILL.md line count <= 500"),
    ("struct-no-windows-paths", "no Windows-style paths (\\\\)"),
    ("struct-reference-depth", "file reference depth <= 1 level from SKILL.md"),
]


def run_checks(skill_dir):
    raw_text, raw_lines, metadata, body, frontmatter_str = load_skill_md(skill_dir)

    results = []
    for check_id, description in CHECKS:
        if check_id == "spec-yaml-valid":
            pass_ = metadata is not None
        elif check_id == "spec-name-present":
            pass_ = check_field_present(metadata, "name")
        elif check_id == "spec-description-present":
            pass_ = check_field_present(metadata, "description")
        elif check_id == "spec-name-matches-dir":
            pass_ = check_name_matches_dir(metadata, skill_dir)
        elif check_id == "spec-name-length":
            pass_ = check_name_length(metadata)
        elif check_id == "spec-name-regex":
            pass_ = check_name_regex(metadata)
        elif check_id == "spec-no-reserved-name":
            pass_ = check_no_reserved_name(metadata)
        elif check_id == "spec-description-non-empty":
            pass_ = check_description_non_empty(metadata)
        elif check_id == "spec-description-length":
            pass_ = check_description_length(metadata)
        elif check_id == "spec-no-xml-name":
            pass_ = check_xml_name(metadata)
        elif check_id == "spec-no-xml-description":
            pass_ = check_xml_description(metadata)
        elif check_id == "spec-compatibility-length":
            pass_ = check_compatibility_length(metadata)
        elif check_id == "spec-license-format":
            pass_ = check_license_format(metadata)
        elif check_id == "spec-description-not-placeholder":
            pass_ = check_description_not_placeholder(metadata)
        elif check_id == "spec-description-no-unquoted-colons":
            pass_ = check_description_no_unquoted_colons(frontmatter_str)
        elif check_id == "struct-skill-md-exists":
            pass_ = check_skill_md_exists(skill_dir)
        elif check_id == "struct-skill-md-lines":
            pass_ = check_skill_md_line_count(raw_lines)
        elif check_id == "struct-no-windows-paths":
            pass_ = check_no_windows_paths(raw_text)
        elif check_id == "struct-reference-depth":
            pass_ = check_reference_depth(skill_dir)
        else:
            pass_ = None

        results.append({"id": check_id, "description": description, "pass": pass_})

    return results


def main():
    if len(sys.argv) != 2:
        print("Usage: validate.py <path/to/skill-directory>", file=sys.stderr)
        sys.exit(1)

    skill_dir = sys.argv[1]
    if not os.path.isdir(skill_dir):
        print(json.dumps({"error": f"Directory not found: {skill_dir}", "checks": []}))
        sys.exit(1)

    results = run_checks(skill_dir)
    output = {
        "target": os.path.abspath(skill_dir),
        "script_checks": results,
    }
    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()
