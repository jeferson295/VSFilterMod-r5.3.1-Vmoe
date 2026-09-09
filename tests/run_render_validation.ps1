param(
    [Parameter(Mandatory = $true)]
    [string]$CurrentDll,
    [string]$ReferenceDll,
    [string]$OutputDirectory = (Join-Path $PSScriptRoot "results")
)

$ErrorActionPreference = "Stop"
$vspipe = (Get-Command vspipe -ErrorAction Stop).Source
$script = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "render_vmoe_tags.vpy")).Path
$fixture = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "vmoe-tags.ass")).Path
$current = (Resolve-Path -LiteralPath $CurrentDll).Path
$reference = if ($ReferenceDll) { (Resolve-Path -LiteralPath $ReferenceDll).Path } else { $null }
$outputRoot = [System.IO.Path]::GetFullPath($OutputDirectory)

$samples = @(
    "ortho-perspective", "ortho-orthographic",
    "xblur", "yblur", "xyblur", "blur-animated",
    "fshp-zero", "fshp-positive", "fshp-negative", "fshp-animated",
    "blend-over", "blend-add", "blend-sub", "blend-mult", "blend-scr", "blend-diff"
)

if (Test-Path -LiteralPath $outputRoot) {
    throw "Output directory already exists; choose a new directory: $outputRoot"
}
New-Item -ItemType Directory -Path $outputRoot | Out-Null

function Invoke-RenderSet {
    param([string]$Name, [string]$Dll)
    $target = Join-Path $outputRoot $Name
    New-Item -ItemType Directory -Path $target | Out-Null
    $rows = @()
    foreach ($sample in $samples) {
        $env:VSFILTERMOD_DLL = $Dll
        $env:VSFILTERMOD_ASS = $fixture
        $env:VSFILTERMOD_SAMPLE = $sample
        $output = Join-Path $target "$sample.y4m"
        & $vspipe --y4m $script $output
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $output)) {
            throw "Render failed for $Name/$sample"
        }
        $hash = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash.ToLowerInvariant()
        $rows += [pscustomobject]@{ Build = $Name; Sample = $sample; SHA256 = $hash }
    }
    return $rows
}

$allRows = @()
$first = Invoke-RenderSet -Name "current-run-1" -Dll $current
$second = Invoke-RenderSet -Name "current-run-2" -Dll $current
$allRows += $first
$allRows += $second

foreach ($sample in $samples) {
    $one = ($first | Where-Object Sample -eq $sample).SHA256
    $two = ($second | Where-Object Sample -eq $sample).SHA256
    if ($one -ne $two) {
        throw "Clean runs differ for sample: $sample"
    }
}

if ($reference) {
    $allRows += Invoke-RenderSet -Name "reference" -Dll $reference
}

$allRows | Export-Csv -LiteralPath (Join-Path $outputRoot "frame-hashes.csv") -NoTypeInformation -Encoding utf8
$allRows | ForEach-Object { "$($_.SHA256)  $($_.Build)/$($_.Sample).y4m" } |
    Set-Content -LiteralPath (Join-Path $outputRoot "SHA256SUMS.txt") -Encoding ascii

$font = Join-Path $env:WINDIR "Fonts\arial.ttf"
$environment = @(
    "OS: $([Environment]::OSVersion.VersionString)",
    "VapourSynth: $(& $vspipe --version 2>&1 | Select-Object -First 1)",
    "Current DLL: $current",
    "Current DLL SHA-256: $((Get-FileHash -LiteralPath $current -Algorithm SHA256).Hash.ToLowerInvariant())",
    "Fixture: $fixture",
    "Fixture SHA-256: $((Get-FileHash -LiteralPath $fixture -Algorithm SHA256).Hash.ToLowerInvariant())",
    "Font for fshp: Arial ($font)",
    "Font SHA-256: $(if (Test-Path -LiteralPath $font) { (Get-FileHash -LiteralPath $font -Algorithm SHA256).Hash.ToLowerInvariant() } else { 'not found' })"
)
if ($reference) {
    $environment += "Reference DLL: $reference"
    $environment += "Reference DLL SHA-256: $((Get-FileHash -LiteralPath $reference -Algorithm SHA256).Hash.ToLowerInvariant())"
}
$environment | Set-Content -LiteralPath (Join-Path $outputRoot "environment.txt") -Encoding utf8

Write-Host "Two clean current-build runs matched for all $($samples.Count) samples."
Write-Host "Results: $outputRoot"
