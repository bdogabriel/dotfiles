_git_info() {
  local branch
  branch=$(git branch --show-current 2>/dev/null)

  if [[ -z "$branch" ]]; then
    local head
    head=$(git rev-parse --short HEAD 2>/dev/null)
    [[ -n "$head" ]] && GIT_PROMPT=" %F{magenta}@%F{white}${head}%f" || GIT_PROMPT=""
    return
  fi

  local s=""
  local porcelain
  porcelain=$(git status --porcelain -b 2>/dev/null)

  local branch_line
  branch_line=$(echo "$porcelain" | head -1)

  [[ "$branch_line" =~ "ahead" ]] && s="${s}↑"
  [[ "$branch_line" =~ "behind" ]] && s="${s}↓"

  local dirty
  dirty=$(echo "$porcelain" | tail -n +2 | awk '
    /^[MADRC] /  { staged=1 }
    /^.[MADRC]/  { unstaged=1 }
    /^\?\?/      { untracked=1 }
    END {
      if (staged)    printf "+"
      if (unstaged)  printf "!"
      if (untracked) printf "?"
    }')

  git stash list 2>/dev/null | grep -q . && dirty="${dirty}\$"

  [[ -n "$dirty" ]] && s="${s}${dirty} "

  local ongoing
  local git_dir
  git_dir=$(git rev-parse --git-dir 2>/dev/null)
  if [[ -d "${git_dir}/rebase-merge" ]] || [[ -d "${git_dir}/rebase-apply" ]]; then
    ongoing=" rebase"
  elif [[ -f "${git_dir}/MERGE_HEAD" ]]; then
    ongoing=" merge"
  elif [[ -f "${git_dir}/CHERRY_PICK_HEAD" ]]; then
    ongoing=" cherry"
  elif [[ -f "${git_dir}/BISECT_LOG" ]]; then
    ongoing=" bisect"
  fi

  [[ -n "$s" ]] && s=" ${s}"

  GIT_PROMPT=" %F{magenta} %F{white}${branch}%F{yellow}${s}%F{red}${ongoing}%f"
}

add-zsh-hook precmd _git_info
