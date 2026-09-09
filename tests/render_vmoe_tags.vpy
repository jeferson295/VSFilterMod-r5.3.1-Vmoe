import os
from pathlib import Path

import vapoursynth as vs


SAMPLES = {
    "ortho-perspective": 12,
    "ortho-orthographic": 36,
    "xblur": 60,
    "yblur": 84,
    "xyblur": 108,
    "blur-animated": 132,
    "fshp-zero": 156,
    "fshp-positive": 180,
    "fshp-negative": 204,
    "fshp-animated": 228,
    "blend-over": 252,
    "blend-add": 276,
    "blend-sub": 300,
    "blend-mult": 324,
    "blend-scr": 348,
    "blend-diff": 372,
}

script_dir = Path(__file__).resolve().parent
dll_path = Path(os.environ["VSFILTERMOD_DLL"]).resolve()
ass_path = Path(os.environ.get("VSFILTERMOD_ASS", script_dir / "vmoe-tags.ass")).resolve()
sample_name = os.environ.get("VSFILTERMOD_SAMPLE", "").strip()

if not dll_path.is_file():
    raise RuntimeError(f"VSFilterMod DLL not found: {dll_path}")
if not ass_path.is_file():
    raise RuntimeError(f"ASS fixture not found: {ass_path}")
if sample_name and sample_name not in SAMPLES:
    raise RuntimeError(f"Unknown sample {sample_name!r}; choose one of: {', '.join(SAMPLES)}")

core = vs.core
core.std.LoadPlugin(path=str(dll_path))
source = core.std.BlankClip(
    width=640,
    height=360,
    length=384,
    fpsnum=24,
    fpsden=1,
    format=vs.YUV420P8,
    color=[32, 128, 128],
)
rendered = core.vsfm.TextSubMod(clip=source, file=str(ass_path))

if sample_name:
    output = rendered[SAMPLES[sample_name]]
else:
    output = core.std.Splice(clips=[rendered[frame] for frame in SAMPLES.values()])

output.set_output()
