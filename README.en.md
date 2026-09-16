# fcitx5-glass-self

[中文](README.md) | **English**

An Fcitx5 candidate window theme, derived from
[sanweiya/fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes)
(`mellow-graphite-dark`). The goal is a **translucent glass look with KWin background
blur and rounded corners**.

This is a **personal configuration**: opacity, blur region and highlight color are tuned
to personal preference. It is published for reference or direct reuse. The upstream
attribution and license are listed at the end of this file.

- Theme directory name: `glass-self`
- Display name: `Glass Self`

## Contents

- [Preview](#preview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Customization](#customization)
  - [Opacity](#opacity)
  - [Highlight color](#highlight-color)
- [Layout](#layout)
- [Known limitations](#known-limitations)
- [Related projects](#related-projects)
- [Field notes](#field-notes)
- [Credits](#credits)
- [License](#license)

## Preview

Candidate window while typing Pinyin in Konsole (translucent rounded background with a
green highlight):

![Candidate window](assets/preview.png)

## Features

| Feature | Implementation |
| --- | --- |
| Translucent background | `fill-opacity: 0.4` in `panel.svg` (measured alpha ~0.52) |
| KWin background blur | `EnableBlur=True` in `theme.conf` |
| Rounded blur region | `BlurMask=blur-mask.png`, so the area outside the rounded corners is not blurred |
| Fixed highlight color | `#31a870`, taken from the upstream mellow-wechat palette |

## Requirements

- **fcitx5**: `EnableBlur` / `BlurMask` require 5.1.x (tested on 5.1.22)
- **KWin**: blur is requested via the Wayland `ext_background_effect_manager_v1` protocol
- **rsvg-convert** (librsvg): used to build the PNG artifacts from the SVG sources

## Installation

```bash
./build.sh     # SVG sources -> PNG artifacts
./install.sh   # install into ~/.local/share/fcitx5/themes/ and push to a running fcitx5
```

The input method process is not restarted; the configuration is pushed to the running
instance over DBus.

## Customization

### Opacity

Edit the `fill-opacity` of the background path in `theme/panel.svg`, then rebuild.
Measured values:

| fill-opacity | Actual alpha |
| --- | --- |
| 0.3 | 0.40 |
| 0.4 | 0.52 (current) |
| 0.5 | 0.63 |
| 0.6 | 0.72 |
| 0.7 | 0.81 |

The measured alpha is higher than the configured value because the SVG contains a drop
shadow filter.

### Highlight color

Edit the `fill` value in `theme/highlight.svg`, then run `./build.sh`.

## Layout

```
theme/
  theme.conf          theme definition
  panel.svg/.png      candidate window background (rounded, translucent)
  highlight.svg/.png  candidate highlight block
  blur-mask.svg/.png  blur region mask
assets/
  preview.png         screenshot used by the README
conf/
  classicui.conf      generated fcitx5 configuration, kept as a reference
build.sh              SVG -> PNG
install.sh            install and push
```

## Known limitations

- **The highlight color cannot follow the system accent color.** In fcitx5, `ThemeImage`
  is either an image or a solid color, never both. An image is required for rounded
  corners but then the color is fixed in the image; a solid color can follow the accent
  color but is drawn as a plain rectangle. This theme keeps the rounded corners.
- **Blur requires KWin.** On compositors that do not implement
  `ext_background_effect_manager_v1` the blur simply does not appear; the rest of the
  theme is unaffected.

## Related projects

This theme only covers the appearance of the candidate window. If you use a Rime schema,
pairing it with the **Wanxiang** grammar model improves the ranking of long-sentence
candidates (without it the input method still works; long sentences simply rely on word
frequency):

- [amzxyz/rime-wanxiang](https://github.com/amzxyz/rime-wanxiang): the input scheme
- [amzxyz/RIME-LMDG](https://github.com/amzxyz/RIME-LMDG): grammar model and dictionary
  data. The LTS model `wanxiang-lts-zh-hans.gram` is about 420 MB; download it from that
  project's Releases page

Notes from testing on fcitx5 5.1.22: download the model into the Rime user directory
(verify the sha256 given on the release page), then write the scheme-level configuration
below and trigger a redeploy.

The values come from
[manateelazycat/rime-ice-installer](https://github.com/manateelazycat/rime-ice-installer),
where they are already validated; `grammar/language` takes the model filename without the
`.gram` extension:

```yaml
# ~/.local/share/fcitx5/rime/rime_ice.custom.yaml
patch:
  "grammar/language": wanxiang-lts-zh-hans
  "grammar/collocation_max_length": 7
  "grammar/collocation_min_length": 2
  "grammar/collocation_penalty": -10
  "grammar/non_collocation_penalty": -20
  "grammar/weak_collocation_penalty": -35
  "grammar/rear_penalty": -12
  "translator/contextual_suggestions": false
  "translator/max_homophones": 5
  "translator/max_homographs": 5
```

Note that this goes into a **scheme-level** file (`rime_ice.custom.yaml`), not the global
`default.custom.yaml`: `grammar/*` and `translator/max_*` are keys of the schema.

**Rime's redeploy has no command-line entry point.** `fcitx5-remote -r` only reloads the
fcitx configuration, the `/rime` DBus interface only exposes schema switching and state
queries, and deactivating then reactivating the input method does not trigger it either.
The only way in is the tray icon: right click, Rime, redeploy. Do not move `build/` away
before confirming how to trigger the redeploy.

Memory footprint measured with the 420 MB model: 400 MB is mapped into the address space
but the resident set is only 64 KB, growing page by page with use. The fcitx5 process RSS
went from 117 MB to 174 MB, most of which is the compiled index and build artifacts
rather than the model itself.

## Field notes

Environment: fcitx5 5.1.22 / KWin 6.7.5 / Wayland

- `classicui.conf` uses bare key/value pairs and **must not contain a section header**
  (writing `[ClassicUI]` makes the whole file unreadable).
- `Theme=` takes the **theme directory name**, not the `Name` from `theme.conf`. The
  system theme directory is `default` while its `theme.conf` carries the localized name
  "Per defecte", which makes a useful cross-check.
- Changing the configuration **does not require restarting fcitx5**:

  ```bash
  gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller \
    --method org.fcitx.Fcitx.Controller1.SetConfig "fcitx://config/addon/classicui" "<{...}>"
  ```

  Editing the file alone, or calling `ReloadConfig`, will not make a running instance
  pick up the new values.
- After changing theme files, force a reload by switching `Theme` to another theme and
  back.
- With `BlurMask` left empty the blur region is a plain rectangle, so the area outside
  the rounded corners is blurred as well; supplying a rounded mask image fixes it.
- A theme directory created while fcitx5 is already running is still picked up, as long
  as `Theme=` holds the correct directory name.

## Credits

- [sanweiya/fcitx5-mellow-themes](https://github.com/sanweiya/fcitx5-mellow-themes):
  base theme and rounded-corner assets (BSD-2-Clause)
- [fcitx5](https://github.com/fcitx/fcitx5): input method framework

## License

BSD-2-Clause, see [LICENSE](LICENSE). This project is a derivative work of the upstream
theme above; the original license text is kept in the repository.
