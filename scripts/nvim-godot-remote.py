#!/usr/bin/env python3

# config in editor:
# exec path: /bin/zsh
# exec flags: -c "source ~/.zshrc && python3 ~/scripts/nvim-godot-remote.py {project} ~/.cache/nvim/godot-$(basename {project}).socket {file} {line} {col}"

import argparse
import os
import shlex
import subprocess
import sys
import time
from pathlib import Path


TERM_EXEC = "kitty"


def run(cmd, **kwargs):
    return subprocess.run(cmd, check=True, **kwargs)


def tmux(args, **kwargs):
    return run(["tmux"] + args, **kwargs)


def nvim_send(socket, cmd):
    run(["nvim", "--server", str(socket), "--remote-send", cmd])


def nvim_responsive(socket):
    result = subprocess.run(
        ["nvim", "--server", str(socket), "--remote-expr", "1"],
        capture_output=True,
    )
    return result.returncode == 0


def socket_ready(socket):
    return socket.exists() and socket.is_socket()


def wait_for_socket(socket, timeout=15):
    deadline = time.time() + timeout
    while time.time() < deadline:
        if socket_ready(socket) and nvim_responsive(socket):
            return
        time.sleep(0.5)
    raise TimeoutError(f"Socket not ready after {timeout}s: {socket}")


def session_exists(name):
    return subprocess.run(["tmux", "has-session", "-t", name], capture_output=True).returncode == 0


def in_tmux():
    return bool(os.environ.get("TMUX"))


def focus_session(name):
    if in_tmux():
        tmux(["switch-client", "-t", name])
    elif sys.stdin.isatty():
        tmux(["attach", "-t", name], capture_output=False)
    else:
        has_clients = subprocess.run(
            ["tmux", "list-clients"], capture_output=True)
        if has_clients.returncode == 0 and has_clients.stdout.strip():
            tmux(["switch-client", "-t", name])
        else:
            subprocess.Popen(
                TERM_EXEC.split() + ["tmux", "attach", "-t", name],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )


def current_window_command(name):
    result = subprocess.run(
        ["tmux", "display-message", "-t", name,
            "-p", "#{pane_current_command}"],
        capture_output=True, text=True,
    )
    return result.stdout.strip().lower()


def start_nvim(session, socket, project_dir, window=None):
    target = f"{session}:{window}" if window else session
    cmd = f"cd {shlex.quote(str(project_dir))
                } && nvim --listen {shlex.quote(str(socket))}"
    tmux(["send-keys", "-t", target, cmd, "C-m"])


def open_file(socket, file_path, line, col):
    nvim_send(socket, f":e +{line} {shlex.quote(str(file_path))}<CR>")
    nvim_send(socket, f":call cursor({line},{col})<CR>")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("project_dir")
    parser.add_argument("socket")
    parser.add_argument("file")
    parser.add_argument("line", type=int)
    parser.add_argument("col", type=int)
    args = parser.parse_args()

    project = Path(args.project_dir).resolve()
    socket = Path(args.socket).resolve()
    socket.parent.mkdir(parents=True, exist_ok=True)
    file_path = Path(args.file).resolve()
    session = project.name

    if socket_ready(socket):
        if session_exists(session):
            # find the window running nvim and switch to it
            result = subprocess.run(
                ["tmux", "list-windows", "-t", session, "-F",
                    "#{window_index}:#{pane_current_command}"],
                capture_output=True, text=True,
            )
            for entry in result.stdout.strip().splitlines():
                idx, cmd = entry.split(":", 1)
                if "nvim" in cmd.lower():
                    tmux(["select-window", "-t", f"{session}:{idx}"])
                    break
            focus_session(session)
        open_file(socket, file_path, args.line, args.col)

    else:
        if session_exists(session):
            focus_session(session)
            window = None
            if current_window_command(session) not in ("zsh", "bash", "sh", "tmux"):
                result = subprocess.run(
                    ["tmux", "new-window", "-t", session, "-c",
                        str(project), "-P", "-F", "#{window_index}"],
                    capture_output=True, text=True, check=True,
                )
                window = result.stdout.strip()
                tmux(["select-window", "-t", f"{session}:{window}"])
            start_nvim(session, socket, project, window)
        else:
            tmux(["new", "-s", session, "-c", str(project), "-d"])
            focus_session(session)
            start_nvim(session, socket, project)

        wait_for_socket(socket)
        open_file(socket, file_path, args.line, args.col)


if __name__ == "__main__":
    main()
