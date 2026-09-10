# Port provenance

This document records the immutable sources used for the Vmoe feature port.
It complements the user-facing README and does not replace the original
copyright notices or license files.

## Source base

The port is based on Masaiki/VSFilterMod tag `r5.3.1`:

- commit: [`effb5a7a5e1aa34dc8023cd03e66acc7f6527bc1`](https://github.com/Masaiki/VSFilterMod/commit/effb5a7a5e1aa34dc8023cd03e66acc7f6527bc1)

The Vmoe behavior was referenced from computerfan/VSFilterMod tag
`r5.2.7-beta`:

- commit: [`e88d88d3e7d4b88243e524994947bf29b98891a6`](https://github.com/computerfan/VSFilterMod/commit/e88d88d3e7d4b88243e524994947bf29b98891a6)

The individual feature commits in that history are:

| Feature | Source commit |
|---|---|
| `\ortho` | [`d9c053682b9d31325a194636b3484e985640445f`](https://github.com/computerfan/VSFilterMod/commit/d9c053682b9d31325a194636b3484e985640445f) |
| `\fshp` | [`2c22244a77266e12647fca8363c5985422286399`](https://github.com/computerfan/VSFilterMod/commit/2c22244a77266e12647fca8363c5985422286399) |
| `\xblur` and `\yblur` | [`582e14b59bb667cceb2394f51bf9f81d544a3243`](https://github.com/computerfan/VSFilterMod/commit/582e14b59bb667cceb2394f51bf9f81d544a3243) |
| original `\blend` implementation | [`cc0dabd3dd395c19dbc712ae702dd2589a8eeab0`](https://github.com/computerfan/VSFilterMod/commit/cc0dabd3dd395c19dbc712ae702dd2589a8eeab0) |
| `\blend` restoration present in `r5.2.7-beta` | [`41a559d5b0980c0f94302c4bd73491b8185d987b`](https://github.com/computerfan/VSFilterMod/commit/41a559d5b0980c0f94302c4bd73491b8185d987b) |

## Adapted source files

The functional port changes these files relative to the Masaiki `r5.3.1`
base:

- `src/subtitles/RTS.cpp`
- `src/subtitles/Rasterizer.cpp`
- `src/subtitles/Rasterizer.h`
- `src/subtitles/STS.cpp`
- `src/subtitles/STS.h`
- `src/subtitles/SeparableFilter.h`

The old commits could not be applied unchanged because the renderer and
rasterizer had evolved between the two source lines. The port therefore adapts
the Vmoe state fields, tag parsing, style copying, directional filtering,
horizontal positioning, and blend propagation to the newer Masaiki code.

Build scripts and documentation in this repository are local maintenance work;
they are not presented as part of either upstream tag.

## Deliberate integration choices

- Existing Masaiki behavior remains the base when a Vmoe tag is absent.
- `\blur` sets both directional Gaussian blur values; `\xblur` and `\yblur`
  set one axis independently.
- Vmoe blend state is propagated through the scalar and SSE2 rasterizer paths.
- Existing vertical spacing remains separate from Vmoe horizontal spacing.
- No upstream tag or commit was rewritten or imported as fabricated history.

## Validation status

- Windows x64 and x86 `Release (MOD)` builds have completed with MSVC toolsets
  `v145` locally and `v143` in GitHub Actions.
- Compilation alone does not validate rendered output.
- Reproducible fixtures for `\ortho`, `\xblur`, `\yblur`, `\fshp`, and
  `\blend` are maintained under `tests/`.
- Reference frame hashes are not considered stable until two clean runs in the
  same documented environment agree.
- Two clean x64 runs of all 16 fixtures matched on Windows 10 build 19045 with
  VapourSynth R69, the `v145` build, and Arial
  `c9b76220a5be42ead4733611e417cd65c5fd8aeaa33eb56576ac378a37d130a1`.
  These environment-specific hashes are recorded in the generated test report,
  not committed as universal reference values.
- A computerfan `r5.2.7-beta` x64 reference compiled with `v145` terminated the
  VapourSynth process with native status `0xC0000409` before rendering its first
  frame. The suspected `\ortho1` difference therefore remains unconfirmed by a
  valid reference render and no functional correction has been made.
- Functional x86 rendering requires a compatible 32-bit host and is tracked
  separately from the x86 compilation check.

## Repository tags

The existing `r5.3.1-Vmoe` tag points to the initial port commit
`0f01dea90f70069b2f7a34cd34e82f5d092efad9`. It intentionally remains
unchanged even though `main` later gained build verification and documentation.

After the audit and functional validation are approved, the planned follow-up
prerelease is `r5.3.1-Vmoe.1`, pointing to the final audited commit. The tag is
not created until the audited `main` state and release package receive final
approval.
