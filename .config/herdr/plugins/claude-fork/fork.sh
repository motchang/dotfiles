#!/usr/bin/env bash
# Fork the Claude Code session running in the current pane into a new split
# pane, carrying over its conversation history via `claude --fork-session`.
# Credit to miyagawa for the original approach:
# https://gist.github.com/miyagawa/cb1a9f6c8695d1219efba0c66d5f78f7
#
# The fork point is not ours to pick. `claude --resume <id> --fork-session`
# starts from whatever the source session's transcript holds on disk at the
# instant the new process reads it, and there are two ways that lands badly:
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
# Both harms need an assistant turn that was started and never finished, so that
# is the only thing the guard holds a fork back for. A transcript whose last
# entry is a *user* entry is usually not that case, whatever put it there - a
# typed message, a slash command, `!` bash mode, a background agent reporting
# in. Nothing needs rewinding and no written answer is at risk; the fork just
# answers it. Letting those through is what keeps the guard from crying wolf,
# and it is by far the commonest tail there is.
#
# "Usually", because a user entry can also land *on top of* a tool call that is
# still open - the tail then looks like an ordinary message while the turn
# underneath is the unfinished kind, and forking rewinds past it after all. So
# the tail test also carries the calls still outstanding on the current turn,
# and judges such a tail as the open call instead. Rare but real: measured over
# the transcripts on this machine it happens in roughly one tool call in ten
# thousand, and every AskUserQuestion left pending - some for the better part of
# an hour - had nothing written under it at all.
#
# Deliberately NOT a whole-file scan for a `tool_use` with no `tool_result`: the
# transcript is a tree, and a branch the user abandoned with an interrupt leaves
# a dangling `tool_use` behind for good, which would block forking forever. The
# tail test has no such false positive.
#
# The guard reports itself by writing into the new pane. Toast notifications are
# disabled on this machine, and while `herdr plugin log list` does record each
# action's stdout and stderr, a log you have to go and query does not reach
# anyone at the moment it matters.
#
# Set CLAUDE_FORK_NO_WAIT=1 to skip the guard and fork immediately.
# Set CLAUDE_FORK_DRY_RUN=1 to print the decision and the herdr calls it implies
# without splitting or running anything.
# Set CLAUDE_FORK_WAIT_SECONDS to change how long an in-flight turn is given.
set -euo pipefail

direction="${1:-right}"
case "$direction" in
  right|down) ;;
  *)
    echo "usage: fork.sh [right|down]" >&2
    exit 1
    ;;
esac

wait_seconds="${CLAUDE_FORK_WAIT_SECONDS:-30}"
case "$wait_seconds" in
  ''|*[!0-9]*) wait_seconds=30 ;;
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

# --- read the tail -----------------------------------------------------------
# Only `assistant` and `user` entries sit *on* the conversation; every other
# .type is a sidecar hanging off it that a fork does not carry (system/*,
# attachment, last-prompt, file-history-snapshot, ai-title, mode, pr-link,
# queue-operation and a growing list besides). Whitelisting the two rather than
# blacklisting the sidecars is deliberate, and load-bearing: sidecars trail the
# final assistant text in the great majority of cleanly finished transcripts, so
# a blacklist would refuse most good forks outright. It also fails in the right
# direction, since a .type added by a future release falls out as "ignore this"
# rather than as "the turn is unfinished".
#
# The interrupt marker Claude Code writes when ESC is pressed is skipped too, on
# the same keep-walking-backwards footing rather than being judged itself. It
# says nothing about the turn underneath, and what is underneath is usually the
# tool result from the call that got interrupted - a turn still in flight, and
# exactly what the guard should be waiting on. Judging the marker itself would
# read as a plain user tail and fork straight past that.
#
# Sets tail_kind (one of complete / empty / message / tool_result / tool_use /
# partial / unreadable) and tail_detail. jq is allowed to fail: the source may
# be appending to this very file, and a half-written last line has to come back
# as `unreadable` - which routes to the wait - rather than take the script down
# under `set -e`. Every array index is `?`-guarded so a content block that is
# not an object cannot throw and be misreported as a torn file.
tail_kind=""
tail_detail=""
read_tail() {
  local out
  out=$(jq -n -r '
    def marker:
      .type == "user"
      and ((.message.content | type) == "array")
      and ([ .message.content[]? | .type? ] == ["text"])
      and ( ((.message.content[0]? | .text?) // "") as $t
            | $t == "[Request interrupted by user]"
              or $t == "[Request interrupted by user for tool use]" );
    def blocks: (.message.content // []) | if type == "array" then . else [] end;
    # One forward pass keeps two things: the last entry that counts as the tail,
    # and the tool calls still outstanding on the turn the tail belongs to.
    # `pending` is emptied at every assistant entry holding a `text` block, so it
    # only ever describes the turn in progress - which is what keeps this a tail
    # test rather than the whole-file tree scan ruled out above. Walking forward
    # rather than backwards is what lets it stay streaming: `pending` holds one
    # small record per unanswered call, never the file.
    reduce ( inputs | select(.type == "assistant" or .type == "user") ) as $e
      ( { last: null, pending: [] };
        ( $e | blocks ) as $b
        | ( if $e.type == "assistant"
               and ( [ $b[]? | select(.type? == "text") ] | length ) > 0
            then .pending = [] else . end )
        | .pending += [ $b[]? | select(.type? == "tool_use")
                        | { id: (.id? // ""), name: (.name? // "") } ]
        | ( [ $b[]? | select(.type? == "tool_result") | .tool_use_id? // "" ] ) as $done
        | .pending = [ .pending[] | select( ([.id] - $done) | length > 0 ) ]
        | ( if ($e | marker) then . else .last = $e end ) )
    | . as $state
    | $state.last
    | if . == null then "empty\t"
      else blocks as $b
        | if .type != "assistant" then
            if ( [ $b[]? | select(.type? == "tool_result") ] | length ) > 0 then
              "tool_result\t"
            elif ( $state.pending | length ) > 0 then
              # A user entry landed on top of a tool call that is still open -
              # a skill body being injected, a background agent reporting in, a
              # message typed while the turn ran. The tail looks like a plain
              # user message, but the turn underneath is the unfinished kind,
              # and forking would rewind past it. Judge it as that instead.
              "tool_use\t" + ($state.pending[0].name)
            else "message\t" end
          else
            ( [ $b[]? | select(.type? == "tool_use") ] | first ) as $open
            | if $open != null then "tool_use\t" + ($open.name? // "")
              elif ( [ $b[]? | select(.type? == "text") ] | length ) > 0 then "complete\t"
              else "partial\t" + ( ( [ $b[]? | .type? ] | first ) // "" )
              end
          end
      end
  ' "$1" 2>/dev/null) || out=""
  [ -n "$out" ] || out=$'unreadable\t'
  IFS=$'\t' read -r tail_kind tail_detail <<<"$out" || true
}

# --- decide ------------------------------------------------------------------
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
  case "$tail_kind" in
    complete)
      reason="the last turn is finished"
      ;;
    message)
      reason="the last entry is a user message, which the fork will answer itself"
      ;;
    empty)
      reason="the transcript holds no conversation to be mid-way through"
      ;;
    tool_use)
      if [ "$agent_status" = "idle" ]; then
        # A tool call with no result, and nothing running to produce one. Unlike
        # the other open-turn tails this will not resolve on its own, so waiting
        # would only postpone the same refusal by wait_seconds.
        decision="refuse"
        reason="an unanswered ${tail_detail:-tool} call, and the source pane is idle"
      else
        decision="wait"
        reason="an unanswered ${tail_detail:-tool} call, and the source pane is $agent_status"
      fi
      ;;
    unreadable)
      # A last line that will not parse means the source process is writing to
      # the file at this very instant, which is itself evidence the turn is in
      # flight. So this is the wait case no matter what the pane status claims:
      # refusing on a transient parse failure would turn a race we can win into
      # a hard stop. A genuinely damaged file still refuses, one timeout later.
      decision="wait"
      reason="the transcript did not parse - the source looks like it is mid-write"
      ;;
    *)
      # tool_result, or an assistant turn that has only got as far as thinking.
      # Both mean the answer is still being written - this is the race, and the
      # case waiting was built for.
      decision="wait"
      reason="the turn is still in flight ($tail_kind)"
      ;;
  esac
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

# zsh echoes a command line before running it, and the refusal is long enough
# that its own quoted source would push the message off a short pane. Clear
# first so what is left on screen is the message and a prompt.
refusal_cmd() {
  local timed_out="${1:-}"
  local lines
  lines=("")
  if [ "$tail_kind" = "unreadable" ]; then
    # Distinct from the mid-turn refusal on purpose: nothing is known about the
    # turn here, and the file itself is the thing to go and look at.
    if [ -e "$transcript" ]; then
      lines+=("Fork not started: the source session's transcript could not be read.")
      lines+=("")
      lines+=("  Its last line still would not parse after ${wait_seconds}s, so the file looks")
      lines+=("  damaged rather than merely mid-write:")
    else
      lines+=("Fork not started: the source session's transcript has gone.")
      lines+=("")
      lines+=("  It disappeared while the guard was watching it:")
    fi
    lines+=("  $transcript")
    lines+=("")
    lines+=("Without reading it there is no way to tell whether the last turn finished, so")
    lines+=("forking might silently drop the tail of the conversation.")
  else
    lines+=("Fork not started: the source session is still mid-turn.")
    lines+=("")
    if [ -n "$timed_out" ]; then
      lines+=("  Waited ${wait_seconds}s for the turn to finish and it did not.")
      lines+=("")
    fi
    case "$tail_kind" in
      tool_use)
        if [ "$tail_detail" = "AskUserQuestion" ]; then
          # The one thing here the user could not have guessed, and the one they
          # can actually act on: the source is blocked on them, not on the model.
          lines+=("  The source is waiting on a question nobody has answered. Answer it in the")
          lines+=("  source pane first and the fork will carry the whole conversation.")
        else
          lines+=("  Its last entry is a ${tail_detail:-tool} call with no result yet.")
        fi
        ;;
      tool_result)
        lines+=("  Its last entry is a tool result the assistant has not replied to yet.")
        ;;
      *)
        lines+=("  Its last entry is ${tail_detail:-partial} output, not a finished answer.")
        ;;
    esac
    lines+=("")
    lines+=("Forking now would rewind past that unfinished turn, so the tail of the")
    lines+=("conversation - including any answer already written inside it - would not")
    lines+=("carry over.")
  fi
  lines+=("")
  lines+=("To fork anyway, paste:")
  lines+=("")
  lines+=("  claude --resume $(shq "$session_id") --fork-session")
  lines+=("")
  printf 'clear; %s' "$(printf_cmd ${lines[@]+"${lines[@]}"})"
}

# The new pane is by construction the source pane's neighbour in $direction, so
# focus can be handed to it without knowing its id.
focus_new_pane() {
  herdr pane focus --pane "$pane_id" --direction "$direction" >/dev/null
}
focus_cmd="herdr pane focus --pane $(shq "$pane_id") --direction $direction"

if [ -n "${CLAUDE_FORK_DRY_RUN:-}" ]; then
  printf 'transcript:   %s\n' "${transcript:-<not found>}"
  printf 'agent_status: %s\n' "$agent_status"
  printf 'tail:         %s\n' "${tail_kind:-<not evaluated>}${tail_detail:+ $tail_detail}"
  printf 'decision:     %s (%s)\n' "$decision" "$reason"
  printf 'herdr pane split --pane %s --direction %s --cwd %s --no-focus\n' \
    "$pane_id" "$direction" "$(shq "$cwd")"
  case "$decision" in
    fork)
      printf 'herdr pane run <new-pane> %s\n' "$fork_cmd"
      printf '%s\n' "$focus_cmd"
      ;;
    wait)
      printf 'herdr pane run <new-pane> %s\n' "$(printf_cmd "$notice_line")"
      printf '# re-test the transcript once a second for up to %ss, then either\n' "$wait_seconds"
      printf 'herdr pane run <new-pane> %s\n' "$fork_cmd"
      printf '# or, on timeout,\n'
      printf 'herdr pane run <new-pane> %s\n' "$(refusal_cmd 1)"
      printf '%s\n' "$focus_cmd"
      ;;
    refuse)
      printf 'herdr pane run <new-pane> %s\n' "$(refusal_cmd)"
      printf '%s\n' "$focus_cmd"
      ;;
  esac
  exit 0
fi

# The split happens now whatever the guard decides: the pane appearing is how
# the user knows the keypress registered, and holding it back to go read a file
# first would make a perfectly good fork feel broken.
#
# It is left unfocused, though. On the waiting path this pane can sit here for
# wait_seconds with a live shell prompt in it, and `pane run` sends its text to
# whatever is already on that command line - so anything typed into a focused
# prompt meanwhile would end up with the fork command glued onto the end of it.
# Focus is handed over at the moment the pane has something to show instead.
split_json=$(herdr pane split --pane "$pane_id" --direction "$direction" --cwd "$cwd" --no-focus)
new_pane_id=$(jq -r '.result.pane.pane_id' <<<"$split_json")

timed_out=""
if [ "$decision" = "wait" ]; then
  herdr pane run "$new_pane_id" "$(printf_cmd "$notice_line")"
  deadline=$(( $(date +%s) + wait_seconds ))
  while :; do
    read_tail "$transcript"
    case "$tail_kind" in
      complete|message|empty)
        decision="fork"
        break
        ;;
    esac
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
focus_new_pane
