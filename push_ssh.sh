#!/usr/bin/env bash
# Helixbox SSH 推送脚本（添加公钥后运行本脚本即可）
set -e
cd "$(dirname "$0")"

echo "==> 测试 SSH 连接"
AUTH=$(ssh -T git@github.com 2>&1 || true)
echo "$AUTH" | head -1
if ! echo "$AUTH" | grep -qi "successfully authenticated"; then
  echo "❌ SSH 未授权。请先把公钥加到 https://github.com/settings/keys："
  echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIFrJqgUWEI1b0FMPGx6P5i5O6hVsKdwCN1fSiqUEZjW helixbox-push"
  exit 1
fi
echo "✅ SSH 已授权"

ORIG=$(git remote get-url origin)
git remote set-url origin git@github.com:liuxiao4538/Helixbox.git
trap 'git remote set-url origin "$ORIG"' EXIT

echo "==> 推送 main"
git push -u origin main

echo "==> 打标签并推送 v1.0.0"
git tag -f v1.0.0
git push -f origin v1.0.0

echo ""
echo "✅ 推送完成：https://github.com/liuxiao4538/Helixbox"
echo "   Actions 将自动编译 APK 并发布 Release（若 workflow 已启用）"
