#!/usr/bin/env bash
# 跟随 KDE 强调色：AccentColor 变化时重新生成 highlight.png 并推给运行中的 fcitx5。
# fcitx5 自身做不到（ThemeImage 是图片和颜色二选一，颜色跟随就丢圆角），所以在外面盯。
#
# 用法：
#   ./accent-watch.sh          常驻监视（Ctrl+C 退出）
#   ./accent-watch.sh --once   立刻同步一次就退出（也用来手动修正）
# 环境变量：
#   KDE_GLOBALS   覆盖配置文件路径（默认 ~/.config/kdeglobals）
#   DRY_RUN=1     只改仓库里的文件，不拷贝、不推给 fcitx5（测试/预览用）
set -euo pipefail
cd "$(dirname "$0")"

NAME=mellow-alpha
THEME="$HOME/.local/share/fcitx5/themes/$NAME"
KDE_GLOBALS="${KDE_GLOBALS:-$HOME/.config/kdeglobals}"
DRY_RUN="${DRY_RUN:-0}"

read_accent() {
    awk -F'[=,]' '
        /^\[General\]/ { g=1; next }
        /^\[/          { g=0 }
        g && $1=="AccentColor" && NF>=4 { printf "#%02X%02X%02X\n", $2, $3, $4; exit }
    ' "$KDE_GLOBALS"
}

push_theme() {
    command -v gdbus >/dev/null 2>&1 || return 0
    fcitx5-remote --check >/dev/null 2>&1 || return 0
    gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller \
        --method org.fcitx.Fcitx.Controller1.SetConfig "fcitx://config/addon/classicui" \
        "<{'Theme': <'default'>, 'DarkTheme': <'default'>}>" >/dev/null
    gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller \
        --method org.fcitx.Fcitx.Controller1.SetConfig "fcitx://config/addon/classicui" \
        "<{'Theme': <'$NAME'>, 'DarkTheme': <'$NAME'>}>" >/dev/null
}

apply() {
    local hex="$1"
    [ -n "$hex" ] || { echo "[!] 没从 $KDE_GLOBALS 读到 AccentColor"; return 1; }
    if grep -qi "$hex" theme/highlight.svg; then
        echo "[=] 高亮已是 $hex，无需改动"
        return 0
    fi
    python3 - "$hex" <<'PY'
import re, sys
hexcol = sys.argv[1]
p = "theme/highlight.svg"
s = open(p, encoding="utf-8").read()
open(p, "w", encoding="utf-8").write(re.sub(r'fill:#[0-9A-Fa-f]{6}', 'fill:' + hexcol, s))
print("[v] theme/highlight.svg 改色 ->", hexcol)
PY
    rsvg-convert -o theme/highlight.png theme/highlight.svg
    if [ "$DRY_RUN" = "1" ]; then
        echo "[i] DRY_RUN：已重新生成 png，跳过拷贝与推送"
        return 0
    fi
    cp -f theme/highlight.svg theme/highlight.png "$THEME/"
    push_theme
    echo "[v] 已重新生成并推给 fcitx5"
}

if [ "${1:-}" = "--once" ]; then
    apply "$(read_accent)"
    exit $?
fi

DIR="$(dirname "$KDE_GLOBALS")"; BASE="$(basename "$KDE_GLOBALS")"

if command -v inotifywait >/dev/null 2>&1; then
    echo "[i] 监听 $KDE_GLOBALS（inotify，零轮询；Ctrl+C 退出）"
    last="$(read_accent)"
    echo "[i] 当前: $last"
    inotifywait -q -m -e close_write,modify,moved_to --format '%f' "$DIR" 2>/dev/null |
    while read -r f; do
        [ "$f" = "$BASE" ] || continue
        cur="$(read_accent)"
        if [ -n "$cur" ] && [ "$cur" != "$last" ]; then
            echo "[*] 强调色变化 $last -> $cur"
            apply "$cur" || true
            last="$cur"
        fi
    done
else
    echo "[i] 没有 inotifywait，退回 3 秒轮询（装 inotify-tools 可换成事件式）"
    last="$(read_accent)"
    echo "[i] 当前: $last"
    while true; do
        sleep 3
        cur="$(read_accent)"
        if [ -n "$cur" ] && [ "$cur" != "$last" ]; then
            echo "[*] 强调色变化 $last -> $cur"
            apply "$cur" || true
            last="$cur"
        fi
    done
fi
