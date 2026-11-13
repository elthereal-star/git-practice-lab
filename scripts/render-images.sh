#!/usr/bin/env bash
# 把 docs/images/*.svg 渲染成 2 倍分辨率 PNG。
# 用途：VSCode / 部分编辑器不加载本地 SVG，需要位图兜底；SVG 仍是唯一的编辑源。
# 用法：bash scripts/render-images.sh

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
IMG_DIR="$REPO/docs/images"
TMP="$(mktemp -d)"
SCALE=2

cleanup() { rm -rf "$TMP" 2>/dev/null || true; }
trap cleanup EXIT

find_browser() {
  local candidates=(
    "/c/Program Files/Google/Chrome/Application/chrome.exe"
    "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"
    "/c/Program Files/Microsoft/Edge/Application/msedge.exe"
    "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
  )
  local c
  for c in "${candidates[@]}"; do
    [ -f "$c" ] && { printf '%s' "$c"; return 0; }
  done
  for c in google-chrome chromium chromium-browser; do
    command -v "$c" >/dev/null 2>&1 && { command -v "$c"; return 0; }
  done
  return 1
}

BROWSER="$(find_browser)" || { echo "错误：没找到 Chrome 或 Edge，无法渲染"; exit 1; }
echo "使用浏览器：$BROWSER"

shopt -s nullglob
for svg in "$IMG_DIR"/*.svg; do
  name="$(basename "$svg" .svg)"
  viewbox="$(grep -o 'viewBox="[^"]*"' "$svg" | head -1)"
  dims="$(printf '%s' "$viewbox" | sed -E 's/.*0 0 ([0-9]+) ([0-9]+).*/\1 \2/')"
  w="${dims%% *}"
  h="${dims##* }"

  if [ -z "$w" ] || [ -z "$h" ] || [ "$w" = "$dims" ]; then
    echo "跳过 $name：viewBox 解析失败（需要形如 viewBox=\"0 0 宽 高\"）"
    continue
  fi

  # 复制到临时目录，用相对路径引用，避免中文目录的 URL 编码问题
  cp "$svg" "$TMP/$name.svg"
  cat > "$TMP/wrap.html" <<HTML
<!doctype html><html><head><meta charset="utf-8">
<style>html,body{margin:0;padding:0;background:#fff;overflow:hidden}
img{display:block;width:${w}px;height:${h}px}</style></head>
<body><img src="$name.svg" alt=""></body></html>
HTML

  "$BROWSER" --headless=new --disable-gpu --hide-scrollbars \
    --force-device-scale-factor="$SCALE" \
    --window-size="$w,$h" \
    --screenshot="$IMG_DIR/$name.png" \
    "file:///$TMP/wrap.html" >/dev/null 2>&1

  size="$(du -k "$IMG_DIR/$name.png" | cut -f1)"
  echo "  ✓ $name.png  ${w}x${h} @${SCALE}x  (${size} KB)"
done

echo "完成。PNG 是渲染产物，不要手改；要改图请编辑同名 .svg 后重新运行本脚本。"
