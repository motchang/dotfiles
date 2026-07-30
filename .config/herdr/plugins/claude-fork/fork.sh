#!/usr/bin/env bash
# Fork the Claude Code session running in the current pane into a new split
# pane, carrying over its conversation history via `claude --fork-session`.
# Approach adapted from https://gist.github.com/miyagawa/cb1a9f6c8695d1219efba0c66d5f78f7
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

if [ -z "$session_id" ]; then
  echo "No Claude Code session detected on pane $pane_id" >&2
  exit 1
fi

split_json=$(herdr pane split --pane "$pane_id" --direction "$direction" --cwd "$cwd" --focus)
new_pane_id=$(jq -r '.result.pane.pane_id' <<<"$split_json")

herdr pane run "$new_pane_id" exec claude --resume "$session_id" --fork-session
