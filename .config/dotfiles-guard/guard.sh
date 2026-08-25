#!/bin/sh
# 公開リポジトリへの機密混入ガード（本体）。
#
# 呼び出し元は <repo>/.githooks/pre-commit と <repo>/.githooks/pre-push（薄いスタブ）。
# 第 1 引数に "pre-commit" か "pre-push" が渡る。
#
# 二層構成:
#   構造ルール   … このファイルに直接書く。会社を特定する文字列は一切書かない。
#   社内語ルール … $GUARD_DIR/patterns に置く。非公開リポから symlink する。
#                  見つからなければ止める（fail closed）。
#
# 適用範囲: core.hooksPath を .githooks に向けた公開リポジトリだけ。
# 会社のリポジトリでは絶対に有効化しないこと（絶対パスも社内語も正当なため）。

set -u

GUARD_DIR=${DOTFILES_GUARD_DIR:-$HOME/.config/dotfiles-guard}
PATTERNS=$GUARD_DIR/patterns
mode=${1:-pre-commit}
hits=0

note() { printf '%s\n' "$*" >&2; }

if [ ! -f "$PATTERNS" ]; then
  note "guard: 社内語パターンが見つかりません: $PATTERNS"
  note ""
  note "  非公開 dotfiles リポジトリを clone し、symlink を張ってください:"
  note "    mkdir -p ~/.config/dotfiles-guard"
  note "    ln -sf <非公開リポ>/.config/dotfiles-guard/patterns ~/.config/dotfiles-guard/patterns"
  note ""
  note "  パターンが無い状態では公開リポジトリへの commit / push を許可しません。"
  exit 1
fi

# ---- push されるコミットの特定（pre-push のみ） ---------------------------
# pre-push は stdin で「<local ref> <local sha> <remote ref> <remote sha>」を受け取る。
# HEAD を見てはいけない: checkout 中のブランチと push 対象は一致するとは限らず、
# 別ブランチを push したときに見当違いのツリーを検査してしまう。
revs=''
if [ "$mode" = pre-push ]; then
  while read -r _lref lsha _rref _rsha; do
    [ -n "${lsha:-}" ] || continue
    case "$lsha" in *[!0]*) revs="$revs $lsha" ;; esac   # 全 0 は ref 削除なので無視
  done
  [ -n "$revs" ] || exit 0
fi

# ---- 対象ファイル ---------------------------------------------------------
case "$mode" in
  pre-commit) files=$(git diff --cached --name-only --diff-filter=ACM) ;;
  pre-push)   files=$(for r in $revs; do git ls-tree -r --name-only "$r"; done | sort -u) ;;
  *) note "guard: 不明なモード: $mode"; exit 1 ;;
esac
[ -n "$files" ] || exit 0

# ---- 走査対象テキストを 1 ファイルに集める --------------------------------
# pre-commit … ステージされた差分の追加行だけ（既存行を蒸し返さない）
# pre-push   … push されるツリーの全文 + push される各コミットの追加行。
#              後者が無いと「一度入れて後のコミットで消した」秘密が、履歴に残った
#              まま公開されてしまう。公開後は履歴も同じだけ読まれる。
tmp=$(mktemp "${TMPDIR:-/tmp}/dotfiles-guard.XXXXXX") || exit 1
trap 'rm -f "$tmp"' EXIT HUP INT TERM

if [ "$mode" = pre-commit ]; then
  printf '%s\n' "$files" | while IFS= read -r f; do
    [ -n "$f" ] || continue
    git diff --cached -U0 --diff-filter=ACM -- "$f" \
      | grep '^+' | grep -v '^+++' | awk -v p="$f" '{print p ": " $0}'
  done > "$tmp"
else
  for r in $revs; do
    git ls-tree -r --name-only "$r" | while IFS= read -r f; do
      [ -n "$f" ] || continue
      git show "$r:$f" 2>/dev/null | awk -v p="$f" '{print p ": " $0}'
    done
    for c in $(git rev-list "$r" --not --remotes 2>/dev/null); do
      short=$(git rev-parse --short "$c")
      git show --format= -U0 "$c" \
        | grep '^+' | grep -v '^+++' | awk -v p="$short" '{print "commit " p ": " $0}'
    done
  done > "$tmp"
fi

# コミット者のメールアドレスも同じルールで検査する（公開されるメタデータのため）。
printf '(git config user.email): %s\n' "$(git config user.email 2>/dev/null)" >> "$tmp"

# macOS の /bin/sh は bash 3.2 で、変数名の解析が UTF-8 に対応していない。$var の
# 直後に全角文字が来ると先頭バイトまで変数名に食い込み、set -u の下では unbound
# variable で異常終了する。日本語に隣接する変数は必ず ${var} と書くこと。
report() {  # report <見出し> <検出結果>
  if [ "$hits" -eq 0 ]; then
    note "guard: 公開リポジトリに出せない内容が含まれています（${mode}）"
    hits=1
  fi
  note "  [$1]"
  printf '%s\n' "$2" | cut -c1-160 | sed 's/^/    /' >&2
}

check() {  # check <正規表現> <説明> [除外正規表現]
  if [ -n "${3:-}" ]; then
    found=$(grep -nE -- "$1" "$tmp" | grep -vE -- "$3")
  else
    found=$(grep -nE -- "$1" "$tmp")
  fi
  [ -n "$found" ] && report "$2" "$found"
  return 0
}

# ---- 構造ルール -----------------------------------------------------------
# 会社を特定する文字列はここには書かない。書けるのは一般形だけ。
U='Users'   # このファイル自身が /${U}/ という並びを含まないようにするための分割
check "/$U/"                      '絶対パス（$HOME か ~ で書く）'
check '/home/[a-z]'               '絶対パス（$HOME か ~ で書く）'  'linuxbrew'
check 'gh[pousr]_[A-Za-z0-9]{20,}'   'GitHub トークン'
check 'github_pat_[A-Za-z0-9_]{20,}' 'GitHub トークン'
check 'AKIA[0-9A-Z]{16}'             'AWS アクセスキー'
check 'xox[baprs]-[A-Za-z0-9-]{10,}' 'Slack トークン'
check 'BEGIN [A-Z ]*PRIVATE KEY'     '秘密鍵'

# ---- 社内語ルール（非公開ファイル由来） -----------------------------------
while IFS= read -r pat || [ -n "$pat" ]; do
  case "$pat" in ''|\#*) continue ;; esac
  found=$(grep -inF -- "$pat" "$tmp")
  [ -n "$found" ] && report "社内語: $pat" "$found"
  hitnames=$(printf '%s\n' "$files" | grep -iF -- "$pat")
  [ -n "$hitnames" ] && report "社内語（ファイル名）: $pat" "$hitnames"
done < "$PATTERNS"

# ---- allowlist の強制（.gitignore を無視ルールから強制ルールへ格上げ） -----
# .gitignore で落ちるはずのパスが staged にあるのは git add -f された証拠。
if [ "$mode" = pre-commit ]; then
  forced=$(printf '%s\n' "$files" | git check-ignore --no-index --stdin 2>/dev/null)
  [ -n "$forced" ] && report 'allowlist 外のパスが force-add されている' "$forced"
fi

if [ "$hits" -ne 0 ]; then
  note ""
  case "$mode" in
    pre-commit) note "  意図的な場合のみ: git commit --no-verify" ;;
    pre-push)   note "  意図的な場合のみ: git push --no-verify" ;;
  esac
  exit 1
fi
exit 0
