#!/usr/bin/env bash
set -euo pipefail

# 颜色定义：荧光蓝 / 荧光粉 / grape紫
CYAN='\033[38;5;51m'    # 荧光蓝
PINK='\033[38;5;201m'   # 荧光粉
GRAPE='\033[38;5;93m'   # grape紫
NC='\033[0m'

# ── 1. 检查是否在 Git 仓库 ──
if [ ! -d ".git" ]; then
  echo -e "${PINK}当前目录不是Git仓库,请先执行 git init${NC}"
  exit 1
fi

# ── 2. 确保在 mytheme 分支 ──
CUR_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CUR_BRANCH" != "mytheme" ]; then
  echo -e "${GRAPE}当前不在mytheme分支，自动切换到mytheme${NC}"
  git checkout mytheme
fi

# ── 3. 判断是否有本地修改 ──
if [ -z "$(git status --porcelain)" ]; then
  echo -e "${CYAN}>>> 无本地变更，拉取远程最新...${NC}"
  if ! git pull --rebase origin mytheme; then
    echo -e "${PINK}拉取冲突，手动解决后重试${NC}"
    exit 1
  fi
else
  echo -n "更新备注喵: "
  read msg
  [ -z "$msg" ] && msg="theme update"

  echo -e "${CYAN}>>> 提交本地修改...${NC}"
  git add .
  git commit -m "$msg"

  echo -e "${CYAN}>>> rebase 到远程最新...${NC}"
  if ! git pull --rebase origin mytheme; then
    echo -e "${PINK}冲突！解决后运行: git add . && git rebase --continue${NC}"
    exit 1
  fi

  echo -e "${CYAN}>>> 推送到远程...${NC}"
  git push origin mytheme
fi

# ── 4. 编译并部署到 GitHub Pages ──
echo -e "${CYAN}>>> 正在清理并生成静态网页喵～...${NC}"
hexo clean
hexo g

echo -e "${CYAN}>>> 正在部署到 GitHub Pages 喵～${NC}"
hexo d

echo -e "${CYAN}>>> 部署与备份完成喵^^！${NC}"

