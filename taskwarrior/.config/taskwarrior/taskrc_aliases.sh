#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Taskwarrior shell aliases
# Usage: Add this line to your ~/.zshrc or ~/.bashrc:
#   source ~/path/to/taskwarrior/taskrc_aliases.sh
# ─────────────────────────────────────────────────────────────────────────────

# ── Core shortcuts ────────────────────────────────────────────────────────────
alias t='task'                          # t add, t next, t done
alias tn='task next'                    # what to work on right now
alias ta='task add'                     # ta "do something" project:ship
alias td='task done'                    # td 3  → mark task 3 done
alias tl='task list'                    # all tasks (simplified view)
alias tls='task long'                   # all tasks (full detail view)
alias ts='task sync'                    # sync with Inthe.AM for iPhone

# ── Daily routine ─────────────────────────────────────────────────────────────
alias today='task due:today'            # tasks due today
alias overdue='task +OVERDUE'           # tasks past their due date
alias soon='task due.before:+3d'        # tasks due in the next 3 days
alias turgent='task +urgent'            # everything tagged urgent

# ── By project ────────────────────────────────────────────────────────────────
alias twork='task project:work'
alias tlearn='task project:learn'
alias tdsa='task project:dsa'
alias tai='task project:ai'
alias tsys='task project:systems'
alias tship='task project:ship'
alias tlife='task project:life'

# ── Quick add by project (ta... shortcuts) ────────────────────────────────────
# Usage: tawork "Fix auth bug" priority:H due:today
alias tawork='task add project:work'
alias talearn='task add project:learn'
alias tadsa='task add project:dsa +quick'
alias taai='task add project:ai'
alias tasyss='task add project:systems'
alias taship='task add project:ship'

# ── Filtering / reporting ─────────────────────────────────────────────────────
alias tquick='task +quick'              # tasks under 15 minutes
alias tblocked='task +blocked'          # blocked tasks
alias tideas='task +idea'               # captured ideas (not committed)
alias treview='task +review'            # things to revisit

# ── Time tracking (Timewarrior) ────────────────────────────────────────────────
alias tw='timew'
alias twstart='timew start'
alias twstop='timew stop'
alias twday='timew summary :day'        # today's tracked time
alias twweek='timew summary :week'      # this week's tracked time

# ── Misc ──────────────────────────────────────────────────────────────────────
alias tclean='task +COMPLETED delete'   # purge completed tasks
alias treport='task burndown.weekly'    # visual weekly progress
alias tcal='task calendar'             # calendar view with due dates
alias tv='vit'                          # open Taskwarrior TUI (install: pip install vit)

# ── Morning standup helper ─────────────────────────────────────────────────────
# Shows: overdue tasks + today's tasks + what's next
morning() {
  echo ""
  echo "══════════════════════════════════════"
  echo "  🌅  Good morning! Here's your day:"
  echo "══════════════════════════════════════"
  echo ""
  echo "── OVERDUE ──────────────────────────"
  task +OVERDUE 2>/dev/null || echo "  (none)"
  echo ""
  echo "── TODAY ────────────────────────────"
  task due:today 2>/dev/null || echo "  (none)"
  echo ""
  echo "── UP NEXT ──────────────────────────"
  task next limit:5
  echo ""
}
