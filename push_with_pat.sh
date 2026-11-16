#!/usr/bin/env bash
# Helixbox 一键发布（PAT 版，绕过 Git 凭据管理器黑窗口/OAuth 报错）
#
# ===== 先生成 PAT（一次性，1 分钟）=====
# 1. 打开 https://github.com/settings/tokens
# 2. Generate new token -> Classic
# 3. Note 随便填，Expiration 选 90 days
# 4. 勾选权限：repo （整个 repo 勾上，包含下面所有子项）
# 5. Generate token，复制那串 ghp_ 开头的字符（只显示一次）
#
# ===== 运行 =====
# 在 Git Bash / PowerShell 里：
#   cd E:/AI/XBOX/xboxdownload-suite
#   GITHUB_TOKEN=ghp_你的令牌 bash push_with_pat.sh
#
# （PowerShell 写法：$env:GITHUB_TOKEN="ghp_你的令牌"; bash push_with_pat.sh）
#
# 令牌只在本次命令的 remote URL 里用，脚本结束自动恢复原 remote，不写入任何文件。
set -e

cd "$(dirname "$0")"

if [ -z "$GITHUB_TOKEN" ]; then
  echo "❌ 请先设置 GITHUB_TOKEN 环境变量，见脚本开头说明。"
  exit 1
fi

echo "==> 当前提交：$(git log --oneline -1)"

ORIG=$(git remote get-url origin)
# 恢复 remote 用的 trap（无论成功失败都执行）
cleanup() { git remote set-url origin "$ORIG"; }
trap cleanup EXIT

git remote set-url origin "https://liuxiao4538:${GITHUB_TOKEN}@github.com/liuxiao4538/Helixbox.git"

echo "==> 推送 main 分支"
git push -u origin main

echo "==> 打标签 v1.0.0 并推送"
git tag -f v1.0.0
git push -f origin v1.0.0

echo ""
echo "✅ 推送完成！GitHub Actions 已触发："
echo "   https://github.com/liuxiao4538/Helixbox/actions"
echo ""
echo "约 5-15 分钟后，Release 页可下载手机 APK 和各架构插件包："
echo "   https://github.com/liuxiao4538/Helixbox/releases/tag/v1.0.0"
