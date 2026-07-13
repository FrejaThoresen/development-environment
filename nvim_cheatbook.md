# Neovim Cheatbook

Tailored to this setup: **LazyVim** + molten/jupytext (notebooks), fugitive + lazygit (git),
nvim-dap (debugging), Copilot, floaterm, remote-sshfs, and the tmux config from
`development-environment`.

Conventions used below:

- `<leader>` = **Space**
- `C-x` = Ctrl+x, `S-x` = Shift+x
- Keys are pressed in sequence unless joined with `-`. So `<leader>ff` = Space, then f, then f.

**The single most useful thing to know:** press `Space` and *wait*. A menu (which-key)
pops up showing every keybinding grouped by topic. Same for `g`, `]`, `[`, `z`. You can
discover 90% of this document interactively that way.

---

## 1. Survival kit (learn these first)

| Keys | Action |
|---|---|
| `i` | Insert mode (type text) |
| `Esc` or `jk` fast | Back to Normal mode |
| `:w` | Save |
| `:q` | Quit window |
| `:wq` / `:q!` | Save and quit / quit without saving |
| `<leader>qq` | Quit nvim entirely |
| `u` / `C-r` | Undo / redo |
| `y` `d` `p` | Copy (yank) / cut (delete) / paste |
| `v` | Visual mode (select with movement keys) |
| `:help X` | Built-in help for anything |

Clipboard is set to the system clipboard (`unnamedplus`), so `y` and `p` work with
other applications — via `xclip` locally, and inside tmux `y` in copy-mode pipes to
xclip too.

Run `vimtutor` in a shell once. It's 25 minutes and teaches the movement model better
than any cheatsheet.

## 2. Moving around

| Keys | Action |
|---|---|
| `h j k l` | Left / down / up / right |
| `w` / `b` / `e` | Next word / back word / end of word |
| `0` / `^` / `$` | Start of line / first char / end of line |
| `gg` / `G` | Top / bottom of file |
| `{` / `}` | Previous / next paragraph (or cell gap) |
| `C-d` / `C-u` | Half page down / up |
| `f x` / `t x` | Jump onto / just before next `x` on the line (`;` repeats) |
| `%` | Jump to matching bracket |
| `s` + 2 chars | **Flash jump**: type two characters, labels appear, press label to teleport anywhere on screen |
| `C-o` / `C-i` | Jump back / forward in jump history |
| `123G` or `:123` | Go to line 123 |

## 3. Editing

| Keys | Action |
|---|---|
| `i` / `a` | Insert before / after cursor |
| `I` / `A` | Insert at line start / end |
| `o` / `O` | New line below / above |
| `x` | Delete character |
| `r x` | Replace character with `x` |
| `dd` / `yy` / `cc` | Delete / yank / change whole line |
| `D` / `C` | Delete / change to end of line |
| `.` | **Repeat last change** (huge) |
| `>` / `<` (visual) | Indent / dedent |
| `gcc` / `gc` (visual) | Toggle comment |
| `C-a` / `C-x` | Increment / decrement number, toggle true↔false, cycle dates (dial.nvim) |
| `<leader>p` | Pick from yank history (yanky) |
| `gsa` / `gsd` / `gsr` | Surround: add / delete / replace (e.g. `gsaiw"` = wrap word in quotes) |

**The grammar:** operators (`d`, `y`, `c`) combine with motions and text objects.
`diw` = delete inner word, `ci"` = change inside quotes, `yap` = yank a paragraph,
`dt)` = delete until `)`. Once this clicks, everything composes — including
`<leader>je` + motion for running code with molten.

Common text objects: `iw`/`aw` word, `i"`/`a"` quotes, `i(`/`a(` parens, `ip`/`ap`
paragraph, `i{` block. Treesitter adds `af`/`if` (function) and `ac`/`ic` (class).

## 4. Files, buffers, search

| Keys | Action |
|---|---|
| `<leader><space>` | Find files (fuzzy) — your main way to open anything |
| `<leader>/` | Live grep across the project |
| `<leader>,` or `<leader>fb` | Switch between open buffers |
| `<leader>e` | File explorer sidebar (toggle) |
| `S-h` / `S-l` | Previous / next buffer (tabs in the bufferline) |
| `<leader>bd` | Close buffer |
| `<leader>fr` | Recent files |
| `<leader>sg` | Grep (same as `<leader>/`) |
| `<leader>sw` | Grep word under cursor |
| `/text` then `n`/`N` | Search in file, next / previous match |
| `<leader>sr` | Search & replace across project (grug-far) |
| `:!mv old new` | Any shell command, e.g. rename a file |
| `<leader>qs` | Restore last session for this directory |

In any picker: type to filter, `C-j`/`C-k` or arrows to move, `Enter` to open,
`C-v` to open in a vertical split, `Esc` to close.

## 5. Windows & splits

| Keys | Action |
|---|---|
| `<leader>-` / `<leader>\|` | Horizontal / vertical split |
| `C-h/j/k/l` | Move between splits (works without prefix) |
| `C-arrow` | Resize split |
| `<leader>wd` | Close split |

## 6. Code intelligence (LSP)

Works out of the box for Python (and everything with a LazyVim `lang` extra —
you have python, cmake, docker, markdown, sql, tex, toml, yaml enabled).
Language servers install automatically via `:Mason`.

| Keys | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | List references |
| `gI` | Go to implementation |
| `K` | Hover docs (press again to enter the float, `q` to close) |
| `<leader>ca` | Code action (auto-import, fixes...) |
| `<leader>cr` | Rename symbol (live preview via inc-rename) |
| `<leader>cf` | Format file/selection |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>cd` | Show diagnostic under cursor |
| `<leader>xx` | All project diagnostics (Trouble) |
| `<leader>ss` | Jump to symbol in file (functions, classes...) |
| `<leader>cs` | Symbol outline sidebar |

Python venvs: `<leader>cv` selects the interpreter (venv-selector); start nvim
with the project venv activated and the LSP/DAP pick it up automatically.

## 7. Git

| Keys | Action |
|---|---|
| `<leader>gg` | **Lazygit** — full TUI: stage with `space`, commit `c`, push `P`, quit `q` |
| `]h` / `[h` | Next / previous changed hunk |
| `<leader>ghs` / `<leader>ghr` | Stage / reset hunk |
| `<leader>ghp` | Preview hunk diff |
| `<leader>gb` | Blame line |
| `:Git` | Fugitive status (`:Git blame`, `:Git log`, any git command) |
| `<leader>gf` | File history |

Day-to-day: edit → `<leader>gg` → stage → commit → push, all without leaving nvim.

## 8. Copilot & AI

| Keys | Action |
|---|---|
| `Tab` (insert mode) | Accept ghost-text suggestion |
| `M-]` / `M-[` | Next / previous suggestion |
| `<leader>aa` | Toggle Copilot Chat |
| `<leader>a` + wait | All AI actions (explain, fix, review selection...) |
| `:Copilot auth` | First-time login |
| `:Copilot status` | Check it's alive |

## 9. Notebooks (molten + jupytext)

Requires a project `.venv` with a registered kernel — see `notebook_cheatsheet.md`
for setup and troubleshooting. Opening an `.ipynb` shows it as markdown, auto-starts
the matching kernel, and imports saved outputs; `:w` writes code *and* outputs back.

| Keys | Action |
|---|---|
| `<leader>ji` | Init / pick a kernel manually |
| `<leader>jl` | Run current line |
| `<leader>jj` (visual) | Run selection — e.g. `vip` then `<leader>jj` runs a cell |
| `<leader>jr` | Re-run current cell |
| `<leader>je` + motion | Run + motion (`<leader>je` `ip` = run paragraph) |
| `<leader>jo` | Enter output window (`q` to leave) |
| `<leader>jh` | Hide output |
| `<leader>jn` / `<leader>jp` | Next / previous cell |
| `<leader>jx` / `<leader>jR` | Interrupt / restart kernel |
| `<leader>jd` | Delete molten cell |

Images render inline (plots etc.) — needs kitty/ghostty/wezterm as your local
terminal; works over SSH and inside tmux with this setup's tmux.conf.

## 10. Debugging (DAP, Python)

Your dap-python config launches with the project root on `PYTHONPATH` and the
project venv's interpreter.

| Keys | Action |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Start / continue (pick "Launch file" or "Launch module") |
| `<leader>dO` / `<leader>di` / `<leader>do` | Step over / into / out |
| `<leader>du` | Toggle debug UI (variables, stack, watches) |
| `<leader>dr` | REPL |
| `<leader>dt` | Terminate |

## 11. Testing (neotest)

| Keys | Action |
|---|---|
| `<leader>tr` | Run nearest test |
| `<leader>tt` | Run current file |
| `<leader>ts` | Toggle test summary sidebar |
| `<leader>to` | Show test output |
| `<leader>td` | Debug nearest test |

## 12. Terminal, markdown, remote

| Keys | Action |
|---|---|
| `C-/` | Toggle terminal (again to hide; `C-/` inside to leave) |
| `:FloatermToggle` | Floating terminal (floaterm) |
| `<leader>cp` | Markdown preview in browser |
| `<leader>rc` / `<leader>rd` | Mount / unmount a remote dir over SSHFS |
| `<leader>rf` / `<leader>rg` | Find files / grep on the remote |

Note on remote work: the usual flow is SSH into the VM inside tmux and run nvim
*there* (everything in this book works identically). remote-sshfs is the alternative
for quick edits of remote files from a local nvim.

## 13. Maintenance & health

| Command | Action |
|---|---|
| `:Lazy` | Plugin manager UI (`S` sync, `U` update, `q` quit) |
| `:Lazy restore` | Roll back all plugins to `lazy-lock.json` (your escape hatch) |
| `:Mason` | LSP/formatter/debugger installer UI |
| `:checkhealth` | Diagnose everything (`:checkhealth molten`, `image`, `provider`) |
| `:UpdateRemotePlugins` | Re-register molten (run after changing the host venv, then restart) |
| `<leader>l` | Open Lazy |

After pulling nvim-config changes on a machine: open nvim, `:Lazy sync`, restart.

## 14. tmux (your config)

Prefix = `C-b`. Press prefix, release, then the key.

| Keys | Action |
|---|---|
| `tmux` / `tmux attach` | Start / reattach (survives SSH disconnects — main reason to use it on VMs) |
| prefix `c` | New window |
| prefix `n` / `p` / `1..9` | Next / previous / jump to window |
| prefix `%` / `"` | Vertical / horizontal split pane |
| prefix `arrow` | Move between panes (mouse also works — it's enabled) |
| prefix `z` | Zoom pane fullscreen (toggle) |
| prefix `d` | Detach (session keeps running) |
| prefix `[` | Copy mode: move with vim keys, `v` select, `y` copy to clipboard, `q` quit |
| prefix `I` | Install plugins (first run after cloning) |
| prefix `R` | Reload tmux.conf |
| prefix `C-s` / `C-r` | Save / restore session layout (resurrect; continuum auto-saves every 15 min) |
| prefix `?` | List all bindings |

Typical VM layout: one tmux session, window 1 nvim, window 2 shell/opencode container,
window 3 logs. Detach, disconnect, reattach tomorrow — everything's still there.

---

## Learning path

Week 1: survival kit + `hjkl w b 0 $ gg G` + `<leader><space>` and `<leader>/`.
Week 2: operators + text objects (`ciw`, `di(`, `yap`) and the `.` repeat.
Week 3: LSP keys (`gd`, `gr`, `K`, `<leader>ca`, `<leader>cr`) and `<leader>gg`.
Then add notebooks/DAP as needed. When lost: `Space` + wait, or `:Tutor`.
