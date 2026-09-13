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

## Validated `\ortho` SSE2 correction

The final comparison used VapourSynth R73 x64, the current x64 build, and the
official computerfan `r5.2.7-beta` x64 DLL. All 16 cases completed. Two clean
current-build executions produced identical output for every case.

Before the SSE2 correction, comparison with computerfan produced:

| Case | Different bytes | Maximum byte difference |
|---|---:|---:|
| `\ortho0` | 191 | 1 level |
| `\ortho1` | 17,098 | 129 levels |

After the correction:

| Case | Different bytes | Maximum byte difference |
|---|---:|---:|
| `\ortho0` | 191 | 1 level |
| `\ortho1` | 326 | 1 level |

Only `ortho-orthographic` changed relative to the previous build. The
`ortho-perspective`, X-only blur, Y-only blur, combined blur, animated blur,
four `\fshp` cases, and six `\blend` cases remained byte-for-byte unchanged.
All six `\blend` cases also continue to match the computerfan reference
exactly. The residual 326-byte `\ortho1` difference, whose maximum difference
is one level, is consistent with minor rounding or rasterization differences
between the two code bases and is not treated as a known rendering error.

Functional x86 validation requires a compatible 32-bit host. The repository CI
currently verifies x86 compilation, not x86 rendered output.
