#!/usr/bin/env bash
# sync-upstream.sh — 一键同步原项目上游代码并合并进 dev
#
# 分支约定: main = 仅本地同步分支(跟踪 upstream/master, 永不推送); dev = 开发分支(推送 origin)
#
# 用法:
#   ./scripts/sync-upstream.sh            # 同步 main -> 合并进 dev -> 推送 dev
#   ./scripts/sync-upstream.sh --no-push  # 只同步/合并, 不推送
#   ./scripts/sync-upstream.sh --rebase   # 用 rebase 代替 merge 合并到 dev
#   ./scripts/sync-upstream.sh --hard     # main 强制对齐 upstream/master (上游重写过历史时用)
#   ./scripts/sync-upstream.sh -m         # 仅同步 main, 不合并/不推送 dev
set -euo pipefail
cd "$(dirname "$0")/.."

MAIN=main
DEV=dev
PUSH=1
MODE=merge
MAIN_MODE=ff
ONLY_MAIN=0

for arg in "$@"; do
  case "$arg" in
    --no-push) PUSH=0 ;;
    --rebase|-r) MODE=rebase ;;
    --hard) MAIN_MODE=hard ;;
    -m|--main-only) ONLY_MAIN=1 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "未知参数: $arg (用 --help 查看用法)" >&2; exit 1 ;;
  esac
done

# 0. 工作区必须干净
if [ -n "$(git status --porcelain)" ]; then
  echo "错误: 工作区有未提交的改动, 请先 commit 或 stash。" >&2
  exit 1
fi

# 1. 同步 main 到上游最新
echo "==> 拉取 upstream 并同步 $MAIN"
git fetch upstream
git checkout "$MAIN" >/dev/null
if [ "$MAIN_MODE" = hard ]; then
  if ! git merge-base --is-ancestor upstream/master "$MAIN" 2>/dev/null; then
    echo "警告: $MAIN 上有上游不存在的本地提交, --hard 将丢弃它们。" >&2
    read -r -p "确认继续? [y/N] " ans
    [ "$ans" = y ] || { echo "已取消"; exit 1; }
  fi
  git reset --hard upstream/master
else
  git merge --ff-only upstream/master
fi

[ "$ONLY_MAIN" = 1 ] && { echo "完成 (仅同步 main)。"; exit 0; }

# 2. 合并到 dev
echo "==> 合并 $MAIN 到 $DEV"
git checkout "$DEV" >/dev/null
if [ "$MODE" = rebase ]; then
  git rebase "$MAIN"
else
  git merge "$MAIN" --no-edit
fi

# 3. 推送 dev
if [ "$PUSH" = 1 ]; then
  echo "==> 推送 $DEV 到 origin"
  git push origin "$DEV"
fi

echo "完成。当前分支: $(git branch --show-current)"
