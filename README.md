# VSFilterMod r5.3.1 Vmoe

VSFilterMod r5.3.1 with the Vmoe subtitle tags from computerfan's
`r5.2.7-beta` ported to the current Masaiki codebase.

## Vmoe tags

- `\ortho0` / `\ortho1` — perspective or orthographic projection
- `\xblur` / `\yblur` — animatable directional blur
- `\fshp` — animatable horizontal spacing
- `\blend` — additional color composition modes

The accepted textual blend modes are `over`, `add`, `sub`, `mult`, `scr` and
`diff`.

Tag documentation: [New tags in Vmoe mod](https://github.com/computerfan/VSFilterMod/wiki/New-Tags#new-tags-in-vmoe-mod)

## Building on Windows

Requirements:

- Visual Studio 2026 with Desktop development with C++
- MFC for the latest x64/x86 build tools
- Windows SDK and the `v145` toolset

Run one of the included scripts:

```bat
build_x64.bat
build_x86.bat
build_all.bat
```

The resulting files are copied to:

```text
dist\x64\VSFilterMod.dll
dist\x86\VSFilterMod.dll
```

The scripts locate Visual Studio automatically and use the `Release (MOD)`
configuration. A Portuguese guide is available in
[`README_PT-BR.md`](README_PT-BR.md).

The confirmed local environment is Visual Studio 2026 with toolset `v145`.
The GitHub Actions workflow also verifies x64 and x86 builds on the Windows
runner with toolset `v143`. Other Visual Studio versions may require changing
`PlatformToolset` in `build_common.bat` or in the workflow.

Compiler warnings inherited from the legacy codebase are expected. The build
is considered successful only when the final DLL exists. Locally compiled DLLs
are not digitally signed.

## VapourSynth usage

```text
vsfm.TextSubMod(clip clip, string file[, int charset=1, float fps=-1.0, string vfr='', int accurate=0])
vsfm.VobSub(clip clip, string file)
```

- `clip`: YUV420P8, YUV420P10, YUV420P16 and RGB24 are supported.
- `accurate`: set to `1` for accurate 10/16-bit rendering (slower), or `0`
  for the default mode.

## MPC-BE

1. Register the matching DLL with `regsvr32.exe VSFilterMod.dll` using an
   elevated command prompt.
2. In MPC-BE, select `VSFilter/xy-VSFilter` as the subtitle renderer.

## Base projects and credits

- [Masaiki/VSFilterMod](https://github.com/Masaiki/VSFilterMod) — r5.3.1 base
- [computerfan/VSFilterMod r5.2.7-beta](https://github.com/computerfan/VSFilterMod/releases/tag/r5.2.7-beta) — Vmoe features
- [sorayuki/VSFilterMod](https://github.com/sorayuki/VSFilterMod)
- [teplofizik/VSFilterMod](https://github.com/teplofizik/vsfiltermod)

This repository preserves the original source notices and is distributed under
the GNU General Public License. See [`LICENSE`](LICENSE).
