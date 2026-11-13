#!/usr/bin/env bash
# 练习 4 重开一局：把 develop 重置到冲突发生之前（140b06d）
# 用法：bash scripts/reset-to-conflict.sh
# 只改本地，不会推送远端。

set -euo pipefail

TARGET=140b06d
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "错误：当前目录不是 git 仓库"
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "错误：工作区有未提交的改动，先处理掉再运行："
  git status --short
  exit 1
fi

if ! git cat-file -e "${TARGET}^{commit}" 2>/dev/null; then
  echo "错误：找不到提交 $TARGET，请先执行 git fetch origin"
  exit 1
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
echo "当前分支：$BRANCH"
echo "目标提交：$TARGET ($(git log -1 --format=%s "$TARGET"))"
echo
echo "将被丢弃的提交："
git log --oneline "${TARGET}..develop" || echo "  （无）"
echo
printf '确认把 develop 重置到 %s ？输入 yes 继续：' "$TARGET"
read -r ans
if [ "$ans" != "yes" ]; then
  echo "已取消，什么都没改。"
  exit 0
fi

# 先打一个备份标签，随时可以还原
git tag -f backup/develop-before-reset develop >/dev/null
git checkout develop
git reset --hard "$TARGET"

echo
echo "完成。现在 develop 指向 $(git rev-parse --short HEAD)。"
echo "下一步：git merge origin/feature/greeting-style  （去制造冲突）"
echo "想反悔：git reset --hard backup/develop-before-reset"
