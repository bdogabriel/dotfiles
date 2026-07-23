_git_info() {
  local branch
  branch=$(git branch --show-current 2>/dev/null)

  if [ -z "$branch" ]; then
    local head
    head=$(git rev-parse --short HEAD 2>/dev/null)
    if [ -n "$head" ]; then
      magenta=$(tput setaf 5)
      white=$(tput setaf 7)
      reset=$(tput sgr0)
      GIT_PROMPT=" ${magenta}@${white}${head}${reset}"
    else
      GIT_PROMPT=""
    fi
    return
  fi

  local s=""
  local porcelain
  porcelain=$(git status --porcelain -b 2>/dev/null)

  local branch_line
  branch_line=$(echo "$porcelain" | head -1)

  case "$branch_line" in
    *ahead*) s="${s}↑" ;;
  esac
  case "$branch_line" in
    *behind*) s="${s}↓" ;;
  esac

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

  [ -n "$dirty" ] && s="${s}${dirty}"

  local ongoing=""
  local git_dir
  git_dir=$(git rev-parse --git-dir 2>/dev/null)
  if [ -d "${git_dir}/rebase-merge" ] || [ -d "${git_dir}/rebase-apply" ]; then
    ongoing=" rebase"
  elif [ -f "${git_dir}/MERGE_HEAD" ]; then
    ongoing=" merge"
  elif [ -f "${git_dir}/CHERRY_PICK_HEAD" ]; then
    ongoing=" cherry"
  elif [ -f "${git_dir}/BISECT_LOG" ]; then
    ongoing=" bisect"
  fi

  [ -n "$s" ] && s=" ${s}"

  magenta=$(tput setaf 5)
  white=$(tput setaf 7)
  yellow=$(tput setaf 3)
  red=$(tput setaf 1)
  reset=$(tput sgr0)
  GIT_PROMPT=" ${magenta} ${white}${branch}${yellow}${s}${red}${ongoing}${reset}"
}

if [ -n "$ZSH_VERSION" ]; then
  add-zsh-hook precmd _git_info
else
  PROMPT_COMMAND="_git_info${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi
