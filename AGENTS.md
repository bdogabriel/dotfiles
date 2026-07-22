# AGENTS.md

This file provides guidance to OpenCode when working with code in this repository.

## Project Overview

This is a personal dotfiles repository containing development environment configurations. The repository is configuration-focused, containing Neovim, shell, terminal, and prompt setups.

### Installation & Setup

This repository is managed with **GNU Stow** for symlinking configuration files to the home directory:

- Configuration files in version control are symlinked to their runtime locations
- Example: `dotfiles/root/.zshrc` -> `~/.zshrc`
- Example: `dotfiles/config/nvim/` -> `~/.config/nvim/`

**Symlinked directories:**
- `root/` -> Home directory files (.zshrc, .tmux.conf, etc.)
- `config/` -> ~/.config/ (Neovim, ghostty, opencode)

To apply changes after pulling updates, run stow from the dotfiles root:
```bash
cd ~/dotfiles
stow --target=$HOME root config
```

Verify symlinks are active:
```bash
ls -la ~/ | grep '^l'  # lists all symlinks in home
```

## Quick Commands

### Neovim Configuration

**View plugin structure:**
```bash
ls config/nvim/lua/plugins/
```

**Update plugin lock file:**
```bash
# From within Neovim
:Lazy sync
```

**Check Neovim health:**
```bash
nvim -c ':checkhealth' -c ':q'
```

**Format Lua files (Stylua):**
```bash
stylua config/nvim/
```

### Shell Configuration

**Reload shell configuration:**
```bash
source ~/.zshrc
```

**View active asdf versions:**
```bash
asdf current
```

### Terminal & Tmux

**View Tmux configuration:**
```bash
cat ~/.tmux.conf
```

**List active Tmux sessions:**
```bash
tmux list-sessions
```

## Architecture & Structure

### Neovim Configuration (`config/nvim/`)

The Neovim setup uses **Lazy.nvim** as the plugin manager with a modular architecture:

**Entry point:** `init.lua` -> loads config modules -> loads plugins

**Config modules** (`lua/config/`):
- `lazy.lua` - Bootstraps lazy.nvim plugin manager with auto-install
- `options.lua` - Core vim options (tabs, indentation, search, UI behavior)
- `keymaps.lua` - Custom keyboard bindings with space as leader key
- `misc.lua` - Colorscheme, auto-commands, and miscellaneous settings

**Plugins** (`lua/plugins/`): 28 plugins organized by function

**LSP & Development:**
- nvim-lspconfig + mason.nvim for language server management
- blink.cmp for completion
- conform.nvim for code formatting
- nvim-treesitter for syntax highlighting
- nvim-dap for debugging
- tiny-inline-diagnostic.nvim for inline diagnostics

**Navigation & UI:**
- snacks.nvim (fuzzy finder, explorer, picker, and UI utilities)
- mini.nvim (files, clue, ai, surround, move, comment, pairs, and more)
- harpoon (quick marks)
- lualine.nvim (status bar)
- nvim-ufo (code folding)
- statuscol.nvim (status column)
- window-picker.nvim (window switching)

**Git Integration:**
- gitsigns.nvim (line-level git indicators)
- neogit (Git UI)
- diffview.nvim (diff viewing)

**Developer Tools:**
- sidekick.nvim (OpenCode CLI integration)
- kulala.nvim (REST client)
- todo-comments.nvim (TODO highlighting)

**Other Notable Plugins:**
- guess-indent.nvim (auto-detect indentation)
- auto-session (session persistence)
- text-case.nvim (text transformations)
- neoscroll.nvim (smooth scrolling)
- highlight-colors.nvim (color preview)
- markdown-preview.nvim (Markdown preview)
- rose-pine (colorscheme)
- vim-tmux-navigator (tmux/Neovim navigation)

Each plugin is configured via lazy.nvim's spec format with conditional loading and lazy loading where appropriate.

### Shell Configuration (`root/`)

**`.zshrc`** - Zsh interactive shell config (225 lines):
- Initializes plugin manager: zinit
- Shell plugins: zsh-syntax-highlighting, zsh-completions, zsh-autosuggestions
- Version managers: asdf, nvm, sdkman
- External tools: fzf, zoxide, ripgrep
- Custom functions for development environment setup
- pnpm package manager
- History and completion settings

**Key external dependencies:**
- fzf - Fuzzy finder used by shell completion
- bat - Syntax-highlighted cat replacement
- ag (The Silver Searcher) - Fast file search
- zoxide - Smart directory navigation

### Terminal & Prompt (`root/` and `config/`)

**`.tmux.conf`** - Tmux configuration (81 lines):
- Prefix: Ctrl+Space (custom, not default Ctrl+B)
- Terminal: tmux-256color
- Theme: rose-pine moon
- Plugins via tpm: vim-tmux-navigator, sensible, yank, resurrect, continuum, rose-pine/tmux
- Continuum auto-save every 15 minutes, auto-restore on start
- Window selection: Ctrl+0-9
- Copy mode with vi keys

**`config/ghostty/config`** - Ghostty terminal config
- Native macOS terminal emulator

**`.zshrc` prompt** - Native zsh prompt with git integration:
- Custom `_git_info` precmd hook showing branch and status flags (+, !, ?)

### OpenCode Configuration (`config/opencode/`)

Contains `AGENTS.md` (global user instructions) and `skills/` (custom OpenCode skills).

## Key Styling & Consistency

**Color Scheme:** rose-pine moon theme consistently applied across:
- Neovim (via rose-pine plugin)
- Tmux (via rose-pine/tmux plugin)
- Ghostty

**Code Formatting:**
- Stylua (Lua formatter) configured in `.stylua.toml`
- conform.nvim integrates formatters for multiple languages
- LSP diagnostics and formatting via nvim-lspconfig

**Git Conventions:**
- Conventional commit format (based on commit history)
- `.gitignore`: Excludes .DS_Store, .env, secrets, .aider/*, docs/

## Important Development Patterns

**Plugin Configuration:**
- Each plugin is a separate file in `lua/plugins/`
- Lazy.nvim spec format: return table with dependencies, config, keys, etc.

**Keybindings:**
- Space is the leader key
- Use vim.keymap.set() with noremap and silent options
- Organize by functionality (navigation, LSP, git, etc.)

**Tmux & Neovim Integration:**
- NVIM_LISTEN_ADDRESS set per tmux session to avoid socket conflicts
- vim-tmux-navigator allows seamless window switching

**Version Management:**
- asdf for polyglot version management
- nvm for Node.js specific management
- sdkman for JVM languages
- Check `asdf current` to verify active versions

## Workspace Context

**Primary Editor:** Neovim with LSP support for:
- Python (pylsp with ruff)
- Lua (with stylua formatting)
- JavaScript/TypeScript
- YAML, JSON, Markdown, etc.

**Git Workflow:**
- Repository at: `/home/bdogabriel/repos/dotfiles`
- Plugin lock file: `config/nvim/lazy-lock.json` (managed by Lazy.nvim)

**Common Edits:**
- Plugin configs: Edit specific file in `lua/plugins/`
- Keybindings: Edit `lua/config/keymaps.lua`
- Shell config: Edit `root/.zshrc`
- LSP/formatting: Edit relevant plugin config or `lua/config/options.lua`
- OpenCode config: Edit files in `config/opencode/`

## When Modifying This Repository

1. **Plugin changes:** Edit file in `lua/plugins/`, then `:Lazy sync` in Neovim
2. **Keymap changes:** Edit `lua/config/keymaps.lua` following existing patterns
3. **Shell changes:** Edit `root/.zshrc`, then `source ~/.zshrc` to reload
4. **Lua formatting:** Run `stylua config/nvim/` before committing
5. **Commit messages:** Follow conventional commit format (feat:, fix:, docs:, refactor:, etc.)
