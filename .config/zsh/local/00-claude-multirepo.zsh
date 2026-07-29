# 00-claude-multirepo.zsh — Claude Code multi-repo launcher (engine)
#
# 汎用エンジン。固有名詞を一切含まないため公開して差し支えない。
# ワークスペース定義は別ファイル（50-workspaces.zsh 等）で与える:
#
#   CLAUDE_MR_ROOT="/path/to/workspace-parent"
#   typeset -gA CLAUDE_MR_PRESETS=( name "base-repo add-repo ..." )
#   typeset -gA CLAUDE_MR_DESC=(    name "説明" )
#   typeset -ga CLAUDE_MR_HEAVY=( repo-with-unscoped-rules )
#
# herdr（https://herdr.dev 的なターミナルワークスペースマネージャ）が動いていれば、
# プリセットの起点リポジトリ名 = herdr workspace のラベルとして自動連携する:
#   - 既存の同名 workspace があればそこに新規タブを開く
#   - なければ workspace を新規作成する
#   - どちらの場合も新しいペインで claude を --add-dir 付きで起動する
# herdr が無ければ何もせず現在のシェルで cd && claude する（従来動作）。
# 無効化: cw -l/--local、または CLAUDE_MR_HERDR=0

typeset -gA CLAUDE_MR_PRESETS CLAUDE_MR_DESC 2>/dev/null
typeset -ga CLAUDE_MR_HEAVY 2>/dev/null

_cw_herdr_available() {
  [[ "${CLAUDE_MR_HERDR:-1}" == "0" ]] && return 1
  command -v herdr >/dev/null 2>&1 || return 1
  command -v jq >/dev/null 2>&1 || return 1
  local sock="${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"
  [[ -S "$sock" ]] || return 1
  herdr api snapshot >/dev/null 2>&1
}

_cw_herdr_find_workspace() {
  herdr workspace list 2>/dev/null | jq -r --arg l "$1" \
    '.result.workspaces[]? | select(.label==$l) | .workspace_id' | head -1
}

_cw_list() {
  if (( ! ${#CLAUDE_MR_PRESETS} )); then
    print -u2 -r -- "cw: プリセット未定義。\$CLAUDE_MR_PRESETS を設定してください"
    return 1
  fi
  print -r -- "usage: cw [-n|--dry-run] [-l|--local] [-b|--background] <preset> [claude args...]"
  print -r -- "  herdr が動いていれば workspace 連携、なければ現シェルで起動"
  print -r --
  local p pw=0
  typeset -A col
  for p in ${(ok)CLAUDE_MR_PRESETS}; do
    local repos=(${=CLAUDE_MR_PRESETS[$p]})
    col[$p]="${repos[1]} ← ${(j:, :)repos[2,-1]}"
    (( ${#p} > pw )) && pw=${#p}
  done
  local indent_n=$(( pw + 3 ))
  local avail=$(( ${COLUMNS:-100} - indent_n ))
  (( avail < 20 )) && avail=20
  local indent
  indent="$(printf '%*s' "$indent_n" '')"

  for p in ${(ok)CLAUDE_MR_PRESETS}; do
    printf "  %-*s %s\n" "$pw" "$p" "${col[$p]}"

    local rest="${CLAUDE_MR_DESC[$p]}"
    if [[ -n "$rest" ]]; then
      local -a lines=()
      while (( ${#rest} > avail )); do
        lines+=("${rest[1,avail]}")
        rest="${rest[avail+1,-1]}"
      done
      lines+=("$rest")

      local i=1
      while (( i <= ${#lines} )); do
        printf "%s%s\n" "$indent" "${lines[$i]}"
        (( i++ ))
      done
    fi
    print -r --
  done
}

cw() {
  local dry=0 force_local=0 background=0
  while [[ "$1" == (-n|--dry-run|-l|--local|-b|--background) ]]; do
    case "$1" in
      -n|--dry-run)    dry=1 ;;
      -l|--local)      force_local=1 ;;
      -b|--background) background=1 ;;
    esac
    shift
  done

  local preset="$1"
  [[ -z "$preset" || "$preset" == (-h|--help|list) ]] && { _cw_list; return $?; }
  shift

  if [[ -z "$CLAUDE_MR_ROOT" ]]; then
    print -u2 -r -- "cw: \$CLAUDE_MR_ROOT が未設定です（ローカル設定が読まれていない可能性）"
    return 1
  fi

  local spec="${CLAUDE_MR_PRESETS[$preset]}"
  if [[ -z "$spec" ]]; then
    print -u2 -r -- "cw: unknown preset '$preset'"
    _cw_list >&2
    return 1
  fi

  local repos=(${=spec})
  local base="${repos[1]}"
  local adds=("${repos[@]:1}")

  local basedir="$CLAUDE_MR_ROOT/$base"
  [[ -d "$basedir" ]] || { print -u2 -r -- "cw: 起点が存在しない: $basedir"; return 1; }

  local -a args missing added
  local load_rules=1 r d
  for r in $adds; do
    d="$CLAUDE_MR_ROOT/$r"
    if [[ ! -d "$d" ]]; then missing+=("$r"); continue; fi
    args+=(--add-dir "$d")
    added+=("$r")
    (( ${CLAUDE_MR_HEAVY[(Ie)$r]} )) && load_rules=0
  done

  (( $#missing )) && print -u2 -r -- "cw: 未クローンのため除外: ${(j:, :)missing}"

  local -a envp
  (( load_rules )) && envp=(env CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1)

  local via_herdr=0 ws_id="" ws_is_new=0
  if (( ! force_local )) && _cw_herdr_available; then
    via_herdr=1
    ws_id=$(_cw_herdr_find_workspace "$base")
    [[ -z "$ws_id" ]] && ws_is_new=1
  fi

  print -r -- "▸ ${preset}: ${base}$( (( $#added )) && print -n -- " ← ${(j:, :)added}")"
  print -r -- "  追加 rules/CLAUDE.md: $( (( load_rules )) && print -n 読む || print -n "読まない (${(j:, :)CLAUDE_MR_HEAVY})")"
  if (( via_herdr )); then
    print -r -- "  経路: herdr workspace \"$base\"$( (( ws_is_new )) && print -n ' (新規作成)' || print -n " ($ws_id に新規タブ)")"
  else
    print -r -- "  経路: ローカルシェル ($( (( force_local )) && print -n -- '-l 指定' || print -n -- 'herdr 未検出'))"
  fi

  if (( dry )); then
    if (( via_herdr )); then
      print -r -- "  \$ herdr $( (( ws_is_new )) && print -n -- "workspace create --label $base" || print -n -- "tab create --workspace $ws_id") --cwd $basedir ... && herdr agent start cw-${preset}-<pane> --kind claude --pane <pane> -- ${(j: :)args} $*"
    else
      print -r -- "  \$ cd $basedir && ${envp:+${(j: :)envp} }claude ${(j: :)args} $*"
    fi
    return 0
  fi

  if (( ! via_herdr )); then
    ( cd "$basedir" && "${envp[@]}" claude "${args[@]}" "$@" )
    return $?
  fi

  # --- herdr 連携パス ---
  local -a herdr_env_flags
  (( load_rules )) && herdr_env_flags=(--env "CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1")
  local -a focus_flags
  (( background )) && focus_flags=(--no-focus) || focus_flags=(--focus)

  local resp
  if (( ws_is_new )); then
    resp=$(herdr workspace create --cwd "$basedir" --label "$base" "${herdr_env_flags[@]}" "${focus_flags[@]}" 2>&1)
  else
    resp=$(herdr tab create --workspace "$ws_id" --cwd "$basedir" --label "cw:${preset}" "${herdr_env_flags[@]}" "${focus_flags[@]}" 2>&1)
  fi

  if ! jq -e '.result.root_pane.pane_id' >/dev/null 2>&1 <<<"$resp"; then
    print -u2 -r -- "cw: herdr でのペイン作成に失敗: $resp"
    return 1
  fi
  local pane_id="$(jq -r '.result.root_pane.pane_id' <<<"$resp")"
  ws_id="$(jq -r '.result.tab.workspace_id' <<<"$resp")"

  # 新規ペインは .zshrc 起動処理(zinit/mise/direnv等)が終わるまで
  # herdr agent start を受け付けない(agent_pane_busy)。準備完了までポーリングする。
  # agent 名は英小文字/数字/-/_ のみ・32文字以内。pane_id は大文字と ':' を含むため使えない。
  # preset はユーザー定義の連想配列キーなので同じ制約が無く、そのまま埋め込むと
  # 大文字/記号や長い名前で herdr agent start が失敗しうる。サニタイズして詰める。
  local preset_safe="${(L)preset}"
  preset_safe="${preset_safe//[^a-z0-9_-]/}"
  preset_safe="${preset_safe[1,15]}"
  local name="cw-${preset_safe}-$$-${RANDOM}" start_resp waited=0
  while true; do
    start_resp=$(herdr agent start "$name" --kind claude --pane "$pane_id" -- "${args[@]}" "$@" 2>&1)
    jq -e '.result.type=="agent_started"' >/dev/null 2>&1 <<<"$start_resp" && break
    if jq -e '.error.code=="agent_pane_busy"' >/dev/null 2>&1 <<<"$start_resp"; then
      sleep 0.4; (( waited += 400 ))
      if (( waited >= 15000 )); then
        print -u2 -r -- "cw: pane が既定時間内に準備できませんでした: $start_resp"
        return 1
      fi
      continue
    fi
    print -u2 -r -- "cw: herdr agent start に失敗: $start_resp"
    return 1
  done

  print -r -- "  → herdr workspace \"$base\" ($ws_id) / pane $pane_id で起動しました"
}

# プリセット名から cw-<name> を自動生成（ローカル設定の読み込み後に呼ぶ）
cw_reload() {
  local p
  for p in ${(k)CLAUDE_MR_PRESETS}; do
    eval "cw-${p}() { cw ${p} \"\$@\" }"
  done
}

_cw() { compadd -- ${(k)CLAUDE_MR_PRESETS} }
compdef _cw cw 2>/dev/null
