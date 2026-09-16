# fcitx5-saya-theme

自用的 Fcitx5 候选窗主题，基于 [sanweiya/fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes)
的 `mellow-graphite-dark` 改造。主题目录名 `mellow-alpha`，显示名 `Mellow Graphite alpha`。

## 相对原主题改了什么

1. `theme.conf` 的 `EnableBlur=True`（原为 False）：在 KWin 下启用候选窗背景模糊。
2. `panel.svg` 的 `fill-opacity` 1 → 0.6：背景半透明，模糊才看得见。
3. 背景图片由 SVG 改为 PNG（`panel.png`）：fcitx5 走 cairo 渲染，PNG 的 alpha 通道最稳。
4. 新增 `blur-mask.svg/png` 并设 `BlurMask=blur-mask.png`：把模糊区域限制成圆角形状。
   留空时 fcitx5 退化成矩形，圆角外面那一圈也会糊。
5. 撤掉 `[InputPanel/Highlight]` 与 `[Menu/Highlight]` 的 `Image`：fcitx5 的 ThemeImage
   是「图片和颜色二选一」，有图片时颜色不参与，撤掉才能让强调色生效。
6. 新增 `[AccentColorField]`，让高亮候选背景跟随系统强调色：

   ```ini
   [AccentColorField]
   0=Input Panel Highlight Candidate Background
   ```

   注意值写的是**显示名**（带空格），不是枚举名。配合 `classicui.conf` 的 `UseAccentColor=True`。
   代价：高亮块失去圆角（纯色背景在 fcitx5 里是直角）。

## 安装

```bash
./build.sh     # SVG 源 -> PNG 产物（改了 svg 之后跑）
./install.sh   # 拷到用户主题目录并推给运行中的 fcitx5
```

## 踩过的坑（fcitx5 5.1.22 / KWin 6.7.5 实测）

- **`classicui.conf` 不能有段头**。它是裸键值（ini 的无名段），写成 `[ClassicUI]` 会整个读不到。
- **`Theme=` 填目录名**，不是 `theme.conf` 里那个 `Name`。系统主题的目录名是 `default`，
  而它 theme.conf 里的 Name 是本地化串「Per defecte」，配置里存的一直是目录名。
- **改配置不用重启 fcitx5**：`gdbus call ... Controller1.SetConfig "fcitx://config/addon/classicui" "<{...}>"`，
  配置路径是 URI 形式。光改文件、跑 `ReloadConfig` 都没用，必须 SetConfig 推给运行中的实例。
- **改主题文件后要触发重载**：把 `Theme` 切到别的再切回来，强制它重读主题目录。
- 主题目录新建的当天 fcitx5 就能用（不必等它重启），前提是 `Theme=` 填的是正确的目录名。
