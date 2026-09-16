#!/usr/bin/env bash
# 装到用户主题目录，并用 DBus 推给运行中的 fcitx5（不重启进程）。
set -euo pipefail
cd "$(dirname "$0")"

NAME=mellow-alpha
THEMES="$HOME/.local/share/fcitx5/themes"
CONF="$HOME/.config/fcitx5/conf/classicui.conf"

mkdir -p "$THEMES/$NAME" "$(dirname "$CONF")"
cp theme/* "$THEMES/$NAME/"
echo "[v] 主题已装到 $THEMES/$NAME"

# classicui.conf：裸键值，千万别加段头
if ! grep -q '^Theme=' "$CONF" 2>/dev/null; then
  cat >> "$CONF" <<EOF
Theme="$NAME"
DarkTheme="$NAME"
UseDarkTheme=False
UseAccentColor=True
EOF
  echo "[v] 已写入 $CONF"
else
  sed -i -E "s|^Theme=.*|Theme=\"$NAME\"|; s|^DarkTheme=.*|DarkTheme=\"$NAME\"|" "$CONF"
  echo "[v] 已更新 $CONF 里的主题名"
fi

# 推给运行中的 fcitx5（失败不致命，说明它没跑）
if fcitx5-remote --check >/dev/null 2>&1; then
  gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller \
    --method org.fcitx.Fcitx.Controller1.SetConfig "fcitx://config/addon/classicui" \
    "<{'Theme': <'$NAME'>, 'DarkTheme': <'$NAME'>, 'UseAccentColor': <'True'>}>" >/dev/null
  echo "[v] 已推给运行中的 fcitx5，切个输入框看看"
else
  echo "[i] fcitx5 没在跑，下次启动即生效"
fi
