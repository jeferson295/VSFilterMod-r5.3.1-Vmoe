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
| `\ortho` SSE2 correction | [`7563c997b62acc1908d10943cdb2a59520110cc8`](https://github.com/computerfan/VSFilterMod/commit/7563c997b62acc1908d10943cdb2a59520110cc8) |
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
- Two clean x64 runs of all 16 fixtures matched with VapourSynth R73 x64. The
  computerfan `r5.2.7-beta` x64 DLL also rendered all 16 cases successfully in
  that environment.
- The initial port incorporated the original `\ortho` implementation from
  `d9c053682b9d31325a194636b3484e985640445f`, but missed the later SSE2 fix in
  `7563c997b62acc1908d10943cdb2a59520110cc8`. As a result, an unconditional
  depth calculation overwrote the zero depth selected by `\ortho1` in the SSE2
  path. The port now includes that correction. The scalar path was already
  correct.
- Against computerfan `r5.2.7-beta`, the corrected `\ortho1` output differs by
  326 bytes with a maximum byte difference of one level, instead of 17,098
  bytes with a maximum difference of 129 levels. `\ortho0` remains at 191 bytes
  with a maximum difference of one level. See `tests/README.md` for the complete
  validation summary.
- An earlier VapourSynth R69 test ended with native status `0xC0000409` while
  loading a separately compiled reference DLL. This was an environment-specific
  historical limitation; the official x64 reference DLL completed normally
  under VapourSynth R73.
- Functional x86 rendering requires a compatible 32-bit host and is tracked
  separately from the x86 compilation check.

## Repository tags

The existing `r5.3.1-Vmoe` tag points to the initial port commit
`0f01dea90f70069b2f7a34cd34e82f5d092efad9`. It intentionally remains
unchanged even though `main` later gained build verification and documentation.

The `r5.3.1-Vmoe.1` prerelease points to
`d61e0ca1365d4410312c40dd68ed2a274495eab5` and preserves the state published
before the SSE2 `\ortho1` correction. The next planned revision is
`r5.3.1-Vmoe.2`; its tag and release are not created until the correction,
validation, documentation, and package receive final approval.
