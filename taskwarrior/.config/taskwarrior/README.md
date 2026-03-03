# Taskwarrior — Your Terminal Task System

## What is Taskwarrior?

Taskwarrior is a **free, offline-first, terminal-native task manager**.
No cloud. No subscription. No slow app to open.
You type `task add` and it's done. It lives in your terminal, integrates with wtf dashboard, syncs to your phone via Inthe.AM, and stores everything as plain files you own forever.

Think of it as: **Notion's task list, but instant, keyboard-driven, and yours.**

---

## Install

```bash
# Arch / Omarchy
sudo pacman -S task timewarrior

# Debian / Ubuntu
sudo apt install taskwarrior timewarrior

# Verify
task --version
timew --version
```

---

## Core Concepts

| Concept | What it means |
|---------|---------------|
| **Task** | A unit of work with a description |
| **Project** | A group of related tasks (`project:work`) |
| **Tag** | A freeform label (`+dsa`, `+ai`, `+ship`) |
| **Priority** | H / M / L (High / Medium / Low) |
| **Due** | A due date (`due:today`, `due:2026-03-10`) |
| **Urgency** | Auto-calculated score — drives what `task next` shows |

---

## Your Workflow

### Projects (your life in buckets)

| Project | What goes in it |
|---------|----------------|
| `work` | Office tasks, PRs, meetings |
| `learn` | Courses, reading, videos |
| `dsa` | LeetCode, algorithms practice |
| `ai` | LLM experiments, RAG projects, model fine-tuning |
| `systems` | C/C++ learning, OS internals, systems projects |
| `ship` | Side projects you're actively building to deploy |
| `life` | Personal admin, health, finance |

### Tags (cross-cutting labels)

| Tag | When to use |
|-----|-------------|
| `+urgent` | Needs to happen today no matter what |
| `+blocked` | Waiting on someone/something else |
| `+quick` | Under 15 minutes — do between deep work |
| `+review` | Needs revisiting / reading |
| `+idea` | Captured idea, not a commitment yet |

---

## Daily Commands

```bash
# See what to work on next (sorted by urgency)
task next

# See today's tasks
task due:today

# Add a task
task add "Write auth middleware" project:work priority:H due:today

# Add a learning task
task add "Complete CS50 Week 4 — Memory" project:learn +review

# Add a DSA task
task add "Solve LeetCode #234 Palindrome LL" project:dsa +quick

# Add a ship task
task add "Set up Dockerfile for project X" project:ship priority:M

# Mark done
task 5 done

# Edit a task
task 5 edit

# Delete a task
task 5 delete

# See all tasks in a project
task project:learn

# See all tasks with a tag
task +urgent

# See everything (all tasks, all projects)
task all
```

---

## Time Tracking (Timewarrior)

```bash
# Start tracking time on a task
timew start project:work

# Stop
timew stop

# See today's tracked time
timew summary

# See this week
timew summary :week
```

---

## Aliases — add these to your `~/.zshrc` or `~/.bashrc`

See `taskrc_aliases.sh` in this folder — copy those lines into your shell config.

---

## Syncing to iPhone (Inthe.AM)

1. Go to [inthe.am](https://inthe.am) — log in with Google (free)
2. Follow the setup — it gives you taskd credentials
3. Add to `~/.taskrc`:
   ```
   taskd.server=inthe.am:53589
   taskd.credentials=your/creds/here
   taskd.certificate=~/.task/inthe.am.cert.pem
   taskd.key=~/.task/inthe.am.key.pem
   taskd.ca=~/.task/inthe.am.ca.pem
   ```
4. Run `task sync` — your tasks now appear in the Inthe.AM web interface on iPhone browser

---

## wtf Dashboard Integration

The `wtf/config.yml` includes a `taskwarrior` module.
It auto-shows your pending tasks directly in the terminal dashboard — no extra setup needed once `task` is installed.

---

## Neovim Integration

Add this alias to open vit (Taskwarrior TUI) in a split:

```bash
alias tv='vit'
```

Or inside Neovim, hit `<C-f>` to open a tmux window and run `task next` there.

You can also add a keymap in Neovim:
```lua
vim.keymap.set('n', '<leader>tw', '<cmd>!task next<CR>', { desc = 'Task: Show next tasks' })
```
