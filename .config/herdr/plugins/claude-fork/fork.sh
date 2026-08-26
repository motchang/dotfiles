#!/usr/bin/env bash
# Fork the Claude Code session running in the current pane into a new split
# pane, carrying over its conversation history via `claude --fork-session`.
# Credit to miyagawa for the original approach:
# https://gist.github.com/miyagawa/cb1a9f6c8695d1219efba0c66d5f78f7
#
# The fork point is not ours to pick. `claude --resume <id> --fork-session`
# starts from whatever the source session's transcript happens to hold on disk
# at the instant the new process reads it, so a source that is mid-turn at that
# instant yields a fork whose conversation is quietly truncated and whose last
# answer is simply missing. Two ways that happens in practice:
#
#   1. A race. The key was pressed while the source was still working, so the
#      answer had not been written out yet. A few seconds of waiting fixes it.
#   2. An unanswered tool call - in the observed cases an AskUserQuestion the
#      user had not answered. The API cannot accept a `tool_use` without its
#      matching `tool_result`, so the fork has to rewind past that whole turn,
#      and any `text` the model emitted in the same turn is discarded with it.
#      One such loss was of text written 6m26s earlier: waiting does not help
#      here, only answering the question does.
#
# One test catches both. Ignoring the sidecar entries a fork drops anyway, the
# last entry in the transcript must be an `assistant` entry holding a `text`
# block and no `tool_use` block. Deliberately NOT a whole-file scan for a
# `tool_use` with no `tool_result`: the transcript is a tree, and a branch the
# user abandoned with an interrupt leaves a dangling `tool_use` behind for good,
# which would block forking forever. The tail test has no such false positive.
#
# The new pane is the only channel that reaches the user - toast notifications
# are disabled on this machine, and whether a plugin action's stderr surfaces
# anywhere at all is unknown - so the guard reports itself by writing into it.
#
# Set CLAUDE_FORK_NO_WAIT=1 to skip the guard and fork immediately.
# Set CLAUDE_FORK_DRY_RUN=1 to print the decision and the herdr calls it implies
# without splitting or running anything.
set -euo pipefail

direction="${1:-right}"
case "$direction" in
  right|down) ;;
  *)
    echo "usage: fork.sh [right|down]" >&2
    exit 1
    ;;
esac

pane_id="${HERDR_PANE_ID:?HERDR_PANE_ID not set — run this action from a pane context}"

pane_json=$(herdr pane get "$pane_id")
session_id=$(jq -r '.result.pane.agent_session.value // empty' <<<"$pane_json")
cwd=$(jq -r '.result.pane.cwd' <<<"$pane_json")

# Read this off the response we already have rather than calling `pane get`
# twice. Observed values on this machine: idle, working, unknown.
agent_status=$(jq -r '.result.pane.agent_status // empty' <<<"$pane_json")
[ -n "$agent_status" ] || agent_status="unknown"

if [ -z "$session_id" ]; then
  echo "No Claude Code session detected on pane $pane_id" >&2
  exit 1
fi

# `pane run` sends literal text to the pane's interactive zsh and presses Enter
# (which is why `exec`, a shell builtin with no binary of that name, works
# there), so anything interpolated into a command has to arrive already quoted.
shq() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

fork_cmd="exec claude --resume $(shq "$session_id") --fork-session"

# --- locate the transcript ---------------------------------------------------
# Transcripts live at <config>/projects/<escaped-cwd>/<session-id>.jsonl. The
# cwd-escaping rule is not worth reimplementing when the session id already
# names the file uniquely; -maxdepth 2 keeps the search cheap and, usefully,
# excludes subagent transcripts, which sit a level deeper under
# <session-id>/subagents/. `find` is allowed to fail - see the fail-open note
# where the decision is made.
claude_config="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
transcript=$(find "$claude_config/projects" -maxdepth 2 -name "$session_id.jsonl" 2>/dev/null | head -1) || true

# --- the completed-turn test -------------------------------------------------
# Only `assistant` and `user` entries sit *on* the conversation. Every other
# .type is a sidecar hanging off it that a fork does not carry: system/*
# (turn_duration, stop_hook_summary, away_summary, informational), attachment,
# last-prompt, file-history-snapshot, ai-title, mode, permission-mode,
# atis-latch, pr-link, queue-operation and more. Whitelisting the two rather
# than blacklisting the sidecars is deliberate, and load-bearing: of the 138
# cleanly-finished transcripts on this machine, 112 have a *non*-`system`
# sidecar sitting after their final assistant text, so a blacklist that only
# skipped `system` would refuse four good forks out of five. The sidecar set
# also grows with Claude Code releases, and an unfamiliar new .type has to fall
# out as "ignore this", never as "the turn is unfinished".
#
# Sets tail_state / tail_kind / tail_detail. jq is allowed to fail: the source
# may be appending to this very file, and a half-written last line should read
# as "not finished yet" rather than take the script down under `set -e`.
tail_state=""
tail_kind=""
tail_detail=""
read_tail() {
  local out
  out=$(jq -n -r '
    last(inputs | select(.type == "assistant" or .type == "user"))
    | if . == null then "incomplete\tnone\t"
      else ( (.message.content // []) | if type == "array" then . else [] end ) as $blocks
        | if .type != "assistant" then
            "incomplete\tuser\t"
            + ( if ( [ $blocks[] | select(.type == "tool_result") ] | length ) > 0
                then "tool_result" else "message" end )
          else
            ( [ $blocks[] | select(.type == "tool_use") ] | first ) as $pending
            | if $pending != null then "incomplete\ttool_use\t" + ($pending.name // "")
              elif ( [ $blocks[] | select(.type == "text") ] | length ) > 0 then "complete\t\t"
              else "incomplete\tassistant\t" + ( ( [ $blocks[].type ] | first ) // "" )
              end
          end
      end
  ' "$1" 2>/dev/null) || out=""
  [ -n "$out" ] || out=$(printf 'incomplete\tunreadable\t')
  IFS=$'\t' read -r tail_state tail_kind tail_detail <<<"$out" || true
  :
}

# --- decide ------------------------------------------------------------------
wait_seconds=30
decision="fork"
reason=""

if [ -n "${CLAUDE_FORK_NO_WAIT:-}" ]; then
  reason="CLAUDE_FORK_NO_WAIT is set"
elif [ -z "$transcript" ]; then
  # Fail open, on purpose. The guard is best-effort and must never become the
  # reason forking is impossible: if the on-disk layout changes under us, the
  # right degradation is "forks exactly like it always did", not "cannot fork".
  reason="no transcript found under $claude_config/projects"
else
  read_tail "$transcript"
  if [ "$tail_state" = "complete" ]; then
    reason="the source session's last turn is complete"
  elif [ "$agent_status" = "idle" ]; then
    # Nothing is running, so nothing is going to finish the turn on its own.
    # Waiting here would only postpone the same refusal by wait_seconds.
    decision="refuse"
    reason="last turn is incomplete and the source pane is idle"
  else
    decision="wait"
    reason="last turn is incomplete and the source pane is $agent_status"
  fi
fi

# --- what the guard says in the pane -----------------------------------------
notice_line="Fork: the source session is mid-turn - waiting up to ${wait_seconds}s for it to finish..."

# `printf '%s\n' a b c` prints one line per argument, so a multi-line message
# stays a single command with every line quoted on its own.
printf_cmd() {
  local cmd="printf '%s\\n'"
  local line
  for line in "$@"; do
    cmd="$cmd $(shq "$line")"
  done
  printf '%s' "$cmd"
}

refusal_lines=()
build_refusal() {
  local timed_out="${1:-}"
  refusal_lines=(
    ""
    "Fork not started: the source session's last turn is incomplete."
    ""
  )
  if [ -n "$timed_out" ]; then
    refusal_lines+=("  Waited ${wait_seconds}s for the turn to finish and it did not.")
    refusal_lines+=("")
  fi
  case "$tail_kind" in
    tool_use)
      if [ "$tail_detail" = "AskUserQuestion" ]; then
        refusal_lines+=("  The source is waiting on a question nobody has answered yet. Answer it in")
        refusal_lines+=("  the source pane first and the fork will carry the whole conversation.")
      elif [ -n "$tail_detail" ]; then
        refusal_lines+=("  The source is sitting on a $tail_detail tool call with no result yet, so the")
        refusal_lines+=("  turn it belongs to is still open.")
      else
        refusal_lines+=("  The source is sitting on a tool call with no result yet, so the turn it")
        refusal_lines+=("  belongs to is still open.")
      fi
      ;;
    user)
      if [ "$tail_detail" = "tool_result" ]; then
        refusal_lines+=("  The source's last entry is a tool result, so the turn that asked for it has")
        refusal_lines+=("  not been answered yet.")
      else
        refusal_lines+=("  The source's last entry is a message to the assistant that has not been")
        refusal_lines+=("  answered yet.")
      fi
      ;;
    assistant)
      refusal_lines+=("  The source's last entry is an assistant ${tail_detail:-non-text} block, so the turn")
      refusal_lines+=("  has not been closed out with an answer.")
      ;;
    unreadable)
      refusal_lines+=("  The transcript could not be parsed - most likely it is being written to")
      refusal_lines+=("  right now.")
      ;;
    *)
      refusal_lines+=("  The transcript has no finished assistant turn at its end.")
      ;;
  esac
  refusal_lines+=("")
  refusal_lines+=("Forking now would rewind past that unfinished turn, so the tail of the")
  refusal_lines+=("conversation - including any answer already written inside it - would not")
  refusal_lines+=("carry over.")
  refusal_lines+=("")
  refusal_lines+=("To fork anyway, paste:")
  refusal_lines+=("")
  refusal_lines+=("  claude --resume $(shq "$session_id") --fork-session")
  refusal_lines+=("")
}

# zsh echoes a command line before running it, and the refusal is long enough
# that its own quoted source would push the message off a short pane. Clear
# first so what is left on screen is the message and a prompt.
refusal_cmd() {
  build_refusal "${1:-}"
  printf 'clear; %s' "$(printf_cmd ${refusal_lines[@]+"${refusal_lines[@]}"})"
}

if [ -n "${CLAUDE_FORK_DRY_RUN:-}" ]; then
  printf 'transcript:   %s\n' "${transcript:-<not found>}"
  printf 'agent_status: %s\n' "$agent_status"
  printf 'tail:         %s\n' "${tail_state:-<not evaluated>}${tail_kind:+ $tail_kind}${tail_detail:+ $tail_detail}"
  printf 'decision:     %s (%s)\n' "$decision" "$reason"
  printf 'herdr pane split --pane %s --direction %s --cwd %s --focus\n' \
    "$pane_id" "$direction" "$(shq "$cwd")"
  case "$decision" in
    fork)
      printf 'herdr pane run <new-pane> %s\n' "$fork_cmd"
      ;;
    wait)
      printf 'herdr pane run <new-pane> %s\n' "$(printf_cmd "$notice_line")"
      printf '# re-test the transcript once a second for up to %ss, then either\n' "$wait_seconds"
      printf 'herdr pane run <new-pane> %s\n' "$fork_cmd"
      printf '# or, on timeout,\n'
      printf 'herdr pane run <new-pane> %s\n' "$(refusal_cmd 1)"
      ;;
    refuse)
      printf 'herdr pane run <new-pane> %s\n' "$(refusal_cmd)"
      ;;
  esac
  exit 0
fi

# The split happens now whatever the guard decides: the pane appearing is how
# the user knows the keypress registered, and holding it back to go read a file
# first would make a perfectly good fork feel broken.
split_json=$(herdr pane split --pane "$pane_id" --direction "$direction" --cwd "$cwd" --focus)
new_pane_id=$(jq -r '.result.pane.pane_id' <<<"$split_json")

timed_out=""
if [ "$decision" = "wait" ]; then
  herdr pane run "$new_pane_id" "$(printf_cmd "$notice_line")"
  deadline=$(( $(date +%s) + wait_seconds ))
  while :; do
    read_tail "$transcript"
    if [ "$tail_state" = "complete" ]; then
      decision="fork"
      break
    fi
    if [ "$(date +%s)" -ge "$deadline" ]; then
      decision="refuse"
      timed_out=1
      break
    fi
    sleep 1
  done
fi

if [ "$decision" = "fork" ]; then
  herdr pane run "$new_pane_id" "$fork_cmd"
else
  herdr pane run "$new_pane_id" "$(refusal_cmd "$timed_out")"
fi
