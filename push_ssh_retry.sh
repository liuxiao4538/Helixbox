#!/usr/bin/env bash
# Helixbox SSH 推送（带网络重试，应对 GitHub 443 间歇性 reset）
set -u
cd "$(dirname "$0")"

ORIG=$(git remote get-url origin)
git remote set-url origin git@github.com:liuxiao4538/Helixbox.git
trap 'git remote set-url origin "$ORIG"' EXIT

# 带重试的 git push：$1=描述，其余为 git push 参数
retry_push() {
  local desc="$1"; shift
  local out rc
  for i in $(seq 1 20); do
    out=$(GIT_SSH_COMMAND="ssh -o ConnectTimeout=8 -o ServerAliveInterval=5 -o ServerAliveCountMax=2" timeout 25 git push "$@" 2>&1); rc=$?
    if [ $rc -eq 0 ]; then
      echo "$out" | tail -3
      return 0
    fi
    echo "  [$desc] 第 $i 次失败: $(echo "$out" | tail -1)"
    sleep 1
  done
  return 1
}

echo "==> 推送 main（最多重试 20 次）"
retry_push "main" -u origin main || { echo "❌ main 推送失败"; exit 1; }
echo "✅ main 已推送"

echo "==> 推送标签 v1.0.0"
git tag -f v1.0.0 >/dev/null 2>&1
retry_push "tag" -f origin v1.0.0 || { echo "❌ 标签推送失败"; exit 1; }
echo "✅ 标签已推送"

echo ""
echo "🎉 全部完成：https://github.com/liuxiao4538/Helixbox"
echo "   Release: https://github.com/liuxiao4538/Helixbox/releases/tag/v1.0.0"
