#!/usr/bin/env bash
# Helixbox 一键发布到 GitHub（在你自己的终端运行，用你自己的 GitHub 凭据）
#
# 用法：
#   cd E:/AI/XBOX/xboxdownload-suite
#   bash publish.sh
#
# 前置条件：本机已用 git 登录 GitHub（任选其一）
#   1) 装了 GitHub CLI 且已登录：gh auth login
#   2) 或用 Personal Access Token（勾 repo 权限）：
#      git config --global credential.helper manager
#      首次 push 时用户名填 liuxiao4538，密码填 PAT
#   3) 或用 GitHub Desktop 登录过本机
#
# 脚本做的事：推送 main → 打 v1.0.0 标签 → 推送标签 → 触发 Actions 云端编译 APK + 生成 Release
set -e

cd "$(dirname "$0")"

echo "==> 当前提交：$(git log --oneline -1)"
echo "==> 目标：https://github.com/liuxiao4538/Helixbox"

# 确保 remote 正确（去掉可能残留的 token）
git remote set-url origin https://github.com/liuxiao4538/Helixbox.git

echo "==> 推送 main 分支（会弹 GitHub 登录/token 提示）"
git push -u origin main

echo "==> 打标签 v1.0.0"
git tag -f v1.0.0
git push -f origin v1.0.0

echo ""
echo "✅ 已触发 GitHub Actions："
echo "   https://github.com/liuxiao4538/Helixbox/actions"
echo ""
echo "约 5-15 分钟后，Release 页面会出现："
echo "   https://github.com/liuxiao4538/Helixbox/releases/tag/v1.0.0"
echo "   - Helixbox-v1.0.0-android-release.apk  （手机安装这个）"
echo "   - Helixbox-v1.0.0-android-debug.apk"
echo "   - ipk/<架构>/ 与 apk/<架构>/ 软路由插件包"
