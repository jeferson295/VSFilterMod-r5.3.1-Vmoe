# Vmoe tag validation

These fixtures render fixed frames for the Vmoe tags without modifying the
filter. They are intended to expose regressions and document actual behavior;
they are not a substitute for code review.

## Requirements

- Windows with VapourSynth R69 or another compatible R4 build;
- `vspipe` available in `PATH`;
- an x64 `VSFilterMod.dll` built from this repository;
- Arial for the `\fshp` samples.

Most samples use ASS vector drawings to avoid font-dependent output. The
`\fshp` samples deliberately use `Arial` because spacing applies to text. The
runner records the font path and SHA-256; hashes from different Windows/font
versions must not be treated as equivalent reference results.

## Run

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/run_render_validation.ps1 `
  -CurrentDll dist/x64/VSFilterMod.dll `
  -OutputDirectory tests/results/current-audit
```

The runner renders every sample twice into a new output directory and fails if
the two clean runs differ. It writes `frame-hashes.csv`, `SHA256SUMS.txt`, and
`environment.txt`. Existing output directories are never deleted or reused.

To compare with a separately obtained or built computerfan reference DLL:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/run_render_validation.ps1 `
  -CurrentDll dist/x64/VSFilterMod.dll `
  -ReferenceDll C:/path/to/reference/VSFilterMod.dll `
  -OutputDirectory tests/results/current-vs-reference
```

## Samples

- `ortho-perspective` and `ortho-orthographic` use the same vector drawing and
  3D rotation. They must differ visibly. The computerfan reference is the
  expected behavioral comparison for `\ortho1`.
- directional blur covers X-only, Y-only, combined, and animated values;
- horizontal spacing covers zero, positive, negative, and animated values;
- blend covers every documented textual mode on overlapping colored shapes.

The current build produces different results for `\ortho0` and `\ortho1`. The
computerfan reference could not be compared because it terminated VapourSynth
with native status `0xC0000409`. There is therefore not enough evidence to call
the current behavior a regression. Do not change renderer code without a valid
reference comparison.

Functional x86 validation requires a compatible 32-bit host. The repository CI
currently verifies x86 compilation, not x86 rendered output.
