#!/bin/bash
# git_sync.sh
# 功能：将当前目录下的 ip.txt 文件强制推送到 GitHub 仓库的 main 分支
# 使用场景：配合 Cloudflare IP 优选工具，自动同步优选结果到远程仓库
#
# ⚠️ 安全提醒：使用前请将下方的 github_token 替换为你自己的 GitHub Personal Access Token
#    切勿将真实令牌提交到公开仓库！

# ==================== GitHub 认证信息（从环境变量读取） ====================
# 个人访问令牌（Personal Access Token），用于身份验证
# 请在系统环境变量中设置：export GITHUB_TOKEN="your_token"
github_token="${GITHUB_TOKEN:-}"
# GitHub 用户名（从环境变量读取）
github_username="${GITHUB_USERNAME:-}"
# 仓库名称（从环境变量读取）
repo_name="${GITHUB_REPO:-}"
# 目标分支（从环境变量读取）
branch="${GITHUB_BRANCH:-main}"

# 检查必要的环境变量
if [ -z "$github_token" ] || [ -z "$github_username" ] || [ -z "$repo_name" ]; then
    echo "⚠️ 环境变量未设置，跳过 GitHub 同步。"
    echo "请设置环境变量："
    echo "  export GITHUB_TOKEN=\"your_token\""
    echo "  export GITHUB_USERNAME=\"your_username\""
    echo "  export GITHUB_REPO=\"your_repo_name\""
    exit 0
fi

# ==================== 切换到脚本所在目录 ====================
cd "$(dirname "$0")" || exit 1

# ==================== 拉取远程最新更新 ====================
git pull origin "$branch"

# ==================== 暂存并提交 ip.txt ====================
git add ip.txt
commit_msg="Update ip.txt on $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$commit_msg"

# ==================== 强制推送到 GitHub ====================
if git push "https://${github_token}@github.com/${github_username}/${repo_name}.git" "$branch" --force; then
    echo "✅ ip.txt 已推送到 GitHub"
else
    echo "❌ ip.txt 推送失败，请检查 Token 和网络配置"
    exit 1
fi