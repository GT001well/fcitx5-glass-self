# fcitx5-glass-self

**中文** | [English](README.en.md)

一个 Fcitx5 候选窗主题，基于 [sanweiya/fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes)
的 `mellow-graphite-dark` 改造，目标是**半透明玻璃质感 + KWin 背景模糊 + 圆角形状**。

这是一份**个人自用**的主题配置：透明度、模糊范围与高亮色均按个人习惯调整，公开出来供参考或直接取用。
上游出处与许可证见文末。

- 主题目录名：`glass-self`
- 显示名：`Glass Self`

## 目录

- [效果](#效果)
- [特性](#特性)
- [环境要求](#环境要求)
- [输入法安装](#输入法安装)
- [主题安装](#主题安装)
- [自定义](#自定义)
  - [透明度](#透明度)
  - [高亮色](#高亮色)
- [目录结构](#目录结构)
- [已知限制](#已知限制)
- [相关项目](#相关项目)
- [实测记录](#实测记录)
- [致谢](#致谢)
- [许可证](#许可证)

## 效果

在 Konsole 中键入拼音时的候选窗（半透明圆角底 + 绿色高亮）：

![候选窗效果](assets/preview.png)

面板模式下的候选窗（关掉「在程序中显示预编辑文本」后，拼音串显示在候选窗里）：

![面板模式下的候选窗](assets/panel-mode.png)

## 特性

| 特性 | 实现 |
| --- | --- |
| 半透明背景 | `panel.svg` 的 `fill-opacity: 0.4`（实测 alpha 约 0.52） |
| KWin 背景模糊 | `theme.conf` 的 `EnableBlur=True` |
| 圆角模糊区域 | `BlurMask=blur-mask.png`，避免圆角外侧一并被模糊 |
| 固定高亮色 | `#31a870`，与上游 mellow-wechat 配色同源 |

## 环境要求

- **fcitx5**：`EnableBlur` / `BlurMask` 需 5.1.x（实测 5.1.22）
- **KWin**：模糊经 Wayland 的 `ext_background_effect_manager_v1` 协议实现
- **rsvg-convert**（librsvg）：用于由 SVG 源生成 PNG 产物（`sudo pacman -S librsvg`）

## 输入法安装

本主题只管外观，要能打字还得先有 fcitx5 + Rime。下面按 Arch 系实测写（版本清单在本节末尾）。

### 官方仓库（extra）

```bash
sudo pacman -S fcitx5-im fcitx5-rime librime
```

`fcitx5-im` 是包组，含四个包：`fcitx5`（本体）、`fcitx5-configtool`（图形配置）、
`fcitx5-gtk` 与 `fcitx5-qt`（GTK / Qt 应用的输入模块，X11 与 XWayland 应用靠它们）。

方案数据也在 extra，按需装：

```bash
sudo pacman -S rime-prelude rime-essay rime-luna-pinyin rime-terra-pinyin rime-stroke
```

想一次带全可以用 meta 包 `librime-data`。不想用 Rime 的话，`fcitx5-chinese-addons` 自带拼音、双拼与五笔。

### 雾凇拼音与万象（archlinuxcn）

雾凇拼音与万象系列都在第三方仓库 archlinuxcn。先在 `/etc/pacman.conf` 末尾追加（镜像按需换）：

```ini
[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
```

再装钥匙环，之后才能装包：

```bash
sudo pacman -Sy archlinuxcn-keyring  # 先装钥匙环
sudo pacman -S rime-ice-git          # 雾凇拼音：方案 + 词库
sudo pacman -S rime-wanxiang-pinyin rime-wanxiang-data rime-wanxiang-gram-zh-hans
                                     # 万象：全拼方案 + 基础数据 + 语法模型
```

包本体装进 `/usr/share/rime-data/`；个人改动写用户目录
`~/.local/share/fcitx5/rime/*.custom.yaml`，别直接改系统目录（升级会覆盖）。

**语法模型不必手动下载**：`rime-wanxiang-gram-zh-hans` 就是那份约 400 MB 的模型
（下载 347 MiB、安装后 400 MiB），交给包管理器跟踪比手放一份可靠。本机目前用的是手动放进
用户目录的 `wanxiang-lts-zh-hans.gram`；若改用包版本，先把用户目录那份挪走，避免两份模型
同时被扫描。

### 环境变量与启动

- Wayland（KDE Plasma）：不需要设输入法环境变量。KWin 通过 `zwp_input_method_v2` 接管，
  指向 `kwinrc` 的 `[Wayland] InputMethod=`（本机指向 `/usr/share/applications/org.fcitx.Fcitx5.desktop`）。
- X11 与 XWayland 应用：需要 `XMODIFIERS=@im=fcitx`（本机写在 `/etc/environment`）；
  X11 下的老式 GTK / Qt 应用另需 `GTK_IM_MODULE=fcitx`、`QT_IM_MODULE=fcitx`。
- 自启：把 `org.fcitx.Fcitx5.desktop` 放进会话（本机在 `~/.config/autostart/`），
  或在系统设置里搜「虚拟键盘」并选中 fcitx5（各 Plasma 版本所在位置不同，搜最稳）。
- 手动起：`fcitx5 -d`；`fcitx5-remote --check` 可以判断是否已经在跑。

### 装完之后

- `Ctrl+Space` 唤出输入法，`fcitx5-remote -n` 看当前输入法名。
2. 分组与方案用 `fcitx5-configtool` 配（比手改 `~/.config/fcitx5/profile` 稳）。
3. 触发 Rime 部署：托盘图标 → 右键 → Rime → 重新部署，或走 DBus 命令（见「相关项目」）。
4. 装本主题：见「主题安装」一节。

本机实测（2026-09-16）：fcitx5 5.1.22 / fcitx5-rime 5.1.16 / librime 1.17.0 /
fcitx5-qt 5.1.15 / fcitx5-gtk 5.1.7 / fcitx5-configtool 5.1.15 / rime-ice-git r994，
全部来自 extra 与 archlinuxcn，没有手工编译的包。

## 主题安装

下面装的是本仓库的主题，不是输入法本体（本体见上一节「输入法安装」）。

```bash
git clone https://github.com/GT001well/fcitx5-glass-self.git
cd fcitx5-glass-self

./build.sh     # SVG 源 -> PNG 产物
./install.sh   # 安装到 ~/.local/share/fcitx5/themes/ 并推给运行中的 fcitx5
```

安装不重启输入法进程；配置通过 DBus 推送给运行中的实例。

## 自定义

### 透明度

修改 `theme/panel.svg` 中背景路径的 `fill-opacity`，随后重新构建。实测对照：

| fill-opacity | 实际 alpha |
| --- | --- |
| 0.3 | 0.40 |
| 0.4 | 0.52（当前） |
| 0.5 | 0.63 |
| 0.6 | 0.72 |
| 0.7 | 0.81 |

实测值高于填写值，原因是 SVG 内叠加有投影滤镜。

### 高亮色

修改 `theme/highlight.svg` 的 `fill`，随后执行 `./build.sh`。

## 目录结构

```
theme/
  theme.conf          主题定义
  panel.svg/.png      候选窗背景（圆角矩形，半透明）
  highlight.svg/.png  候选高亮块
  blur-mask.svg/.png  模糊区域遮罩
assets/
  preview.png         README 用的效果截图
  panel-mode.png      面板模式下的候选窗截图
conf/
  classicui.conf      fcitx5 生成的配置样本，供对照配置项
build.sh              SVG -> PNG
install.sh            安装与推送
```

## 已知限制

- **高亮色不能跟随系统强调色。** fcitx5 的 `ThemeImage` 在「背景图片」与「纯色」之间二选一：
  使用图片才有圆角，但颜色由图片固定；使用纯色才能跟随强调色，但退化为直角矩形。
  本主题选择保留圆角。
- **模糊依赖 KWin。** 合成器未实现 `ext_background_effect_manager_v1` 时模糊不生效，
  主题的其余部分不受影响。

## 相关项目

本主题只负责候选窗的外观。若你使用 Rime（中州韵）方案，搭配**万象拼音**的语法模型可以改善长句
候选的排序（不启用时输入法照常工作，只是长句会更依赖词频）：

- [amzxyz/rime-wanxiang](https://github.com/amzxyz/rime-wanxiang)：输入方案本体
- [amzxyz/RIME-LMDG](https://github.com/amzxyz/RIME-LMDG)：语法模型与词库数据。
  LTS 版 `wanxiang-lts-zh-hans.gram` 约 420 MB，请在该项目的 Releases 页面下载

模型文件体积过大，不适合随本仓库分发，因此仅指向上游；上游保持更新，比固化一份副本更可靠。
Arch 系且启用了 archlinuxcn 的用户可以直接装 `rime-wanxiang-gram-zh-hans`（见[输入法安装](#输入法安装)），
不必手动下载这份约 420 MB（400 MiB）的模型。

方案级配置 `rime_ice.custom.yaml` 的内容如下（对应下面安装要点的第 2 步；值取自 [manateelazycat/rime-ice-installer](https://github.com/manateelazycat/rime-ice-installer)
已验证的参数；`grammar/language` 填模型文件名去掉 `.gram` 后缀的部分）：

```yaml
# ~/.local/share/fcitx5/rime/rime_ice.custom.yaml
patch:
  "grammar/language": wanxiang-lts-zh-hans        # 模型文件名去掉 .gram
  "grammar/collocation_max_length": 7             # 参与搭配打分的词组长度上限
  "grammar/collocation_min_length": 2             # 下限（整句输入时这两项可忽略）
  "grammar/collocation_penalty": -10              # 成搭配的权重
  "grammar/non_collocation_penalty": -20          # 不成搭配的惩罚
  "grammar/weak_collocation_penalty": -35         # 弱搭配的惩罚
  "grammar/rear_penalty": -12                     # 出现在句尾时的惩罚
  "translator/contextual_suggestions": false      # 上下文加权：true 时用刚上屏的文本给候选加分
  "translator/max_homophones": 5                  # 同一位置取几个同音候选
  "translator/max_homographs": 5                  # 同一位置取几个同形候选
```

上面注释里的语义按 librime 源码核过：`contextual_suggestions` 决定是否调用
`Poet::ContextualWeighted()` 拿前文与上屏历史给候选加权（即跨句联想），
与句内的 `grammar/*` 是两套机制；`max_homophones` 对应
`while (homophones.size() < max_homophones())` 那个循环的上限。

注意配置文件要挂在**方案级**（`rime_ice.custom.yaml`），不是全局的 `default.custom.yaml` ——
`grammar/*` 与 `translator/max_*` 都是方案（schema）里的键。

安装要点（实测于 fcitx5 5.1.22）：

```bash
# 1. 下载到 Rime 用户目录（上游 release 页给出 sha256，建议校验）
cd ~/.local/share/fcitx5/rime
curl -LO https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram
sha256sum wanxiang-lts-zh-hans.gram   # 应等于 8f1b2d3ed2b2755fdd445f6ab103eff613052080b62a0c049f4b166043a16ac4
# 上面这个值对应当前 LTS 资产，上游重新打包后请以 release 页为准

# 2. 写 scheme 级配置（内容见上）
# 3. 触发重新部署（下一步）
```

**触发 Rime 重新部署有两个入口，二选一**（实测于 fcitx5 5.1.22 / librime 1.17.0）：
输入法托盘图标 → 右键 → Rime → 重新部署，或者直接调 controller 上的 `SetConfig`：

```bash
gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller \
  --method org.fcitx.Fcitx.Controller1.SetConfig "fcitx://config/addon/rime/deploy" "<@a{ss} {}>"
```

走的是 `rime` 附加组件的 `deploy` 子配置，**不是 `/rime` 接口**（那儿只有
`GetCurrentSchema` / `ListAllSchemas` / `IsAsciiMode` / `SetSchema` / `SetAsciiMode`）。
`fcitx5-remote -r` 只重载 fcitx 侧配置，不触发 Rime 部署；`"<@a{ss} {}>"` 也别写成 `"<{}>"`
（gdbus 推不出空字典的类型）。验证部署真的跑了：`~/.local/share/fcitx5/rime/user.yaml`
里的 `last_build_time` 会变。动手前先确认触发手段，别先把 `build/` 挪走再去研究怎么部署。

内存占用实测（420 MB 模型）：映射进地址空间 400 MB，**实际驻留 RSS 仅 64 KB**，
随使用按页增长；fcitx5 进程总 RSS 从 117 MB 涨到 174 MB，增量主要来自编译出的索引与
`build/` 产物，而非模型本身。

## 实测记录

环境：fcitx5 5.1.22 / KWin 6.7.5 / Wayland

- `classicui.conf` 为裸键值格式，**不能带段头**（写成 `[ClassicUI]` 会导致整个文件读取失败）。
- `Theme=` 填写**主题目录名**，而非 `theme.conf` 中的 `Name`。系统主题的目录名为 `default`，
  其 `theme.conf` 中的 `Name` 是本地化字符串「Per defecte」，可作旁证。
- 修改配置**无需重启 fcitx5**：

  ```bash
  gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller \
    --method org.fcitx.Fcitx.Controller1.SetConfig "fcitx://config/addon/classicui" "<{...}>"
  ```

  仅修改文件、或调用 `ReloadConfig`，运行中的实例都不会读取新值。
- 修改主题文件后需触发重载：将 `Theme` 切换到其他主题再切回，强制重新读取主题目录。
- `BlurMask` 留空时模糊区域为矩形，圆角外侧同样被模糊；提供圆角形状的遮罩图即可修正。
- 主题目录于运行期间新建同样可被识别，前提是 `Theme=` 填写的是正确的目录名。
- **拼音串里按左右键移动插入点，界面上不会出现光标。** Rime 1.17 的 `navigator` 确实绑了
  `←`/`→` 按字符移动（`left_by_char_no_loop`）、加 `Shift` 按音节移动（`left_by_syllable`，
  本机在雾凇方案的 `default.yaml` 里可核对），移动后候选词也会跟着变，但看不到插入点落在哪。
  两处原因：一是 fcitx5-rime 的 `PreeditCursorPositionAtBeginning`（Linux 默认 `true`，
  源码注释写明是为了让候选窗不跟着抖）会把送进应用的预编辑光标强制设为 0；二是应用侧
  （实测 KWrite）只在拼音串上压一块高亮，不画竖线，也不闪。
- 想边打边看位置，只能让预编辑改由 fcitx5 自己的候选面板显示：关掉「在程序中显示预编辑文本」
  （临时用 `Ctrl+Alt+P`）。此时面板里的拼音串自带一条竖直光标，按左右键它会跟着走，
  代价是拼音不再内联、看不到上下文。面板模式的样子见上面「效果」的第二张图。
- `conf/` 下所有附加组件配置与 `classicui.conf` 一样是裸键值格式，**同样不能加段头**
  （例如 `rime.conf` 里写 `PreeditCursorPositionAtBeginning=False`，加了 `[Rime]` 段头就整个读不到）。

## 致谢

- [sanweiya/fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes)：基础主题与圆角素材（BSD-2-Clause）
- [fcitx5](https://github.com/fcitx/fcitx5)：输入法框架

## 许可证

BSD-2-Clause，见 [LICENSE](LICENSE)。本项目为上述上游主题的衍生作品，原许可证文本随附保留。
