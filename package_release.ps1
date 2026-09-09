[CmdletBinding()]
param(
    [ValidatePattern('^v\d{3}$')]
    [string] $Toolset,

    [string] $OutputDirectory = (Join-Path $PSScriptRoot 'release-output')
)

$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
$outputRoot = [System.IO.Path]::GetFullPath($OutputDirectory)
$temporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$stagingRoot = Join-Path $temporaryRoot ("VSFilterMod-package-{0}" -f [guid]::NewGuid().ToString('N'))
$archiveName = 'VSFilterMod-r5.3.1-Vmoe-binaries.zip'
$archivePath = Join-Path $outputRoot $archiveName
$checksumPath = "$archivePath.sha256"

if ($outputRoot.TrimEnd('\') -eq $repositoryRoot.TrimEnd('\')) {
    throw 'OutputDirectory must be a dedicated directory, not the repository root.'
}

if ((Test-Path -LiteralPath $archivePath) -or (Test-Path -LiteralPath $checksumPath)) {
    throw "Output already exists. Choose an empty directory: $outputRoot"
}

New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $stagingRoot 'x86') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $stagingRoot 'x64') -Force | Out-Null

try {
    $buildScript = Join-Path $repositoryRoot 'build_all.bat'
    $buildArguments = if ($Toolset) { @($Toolset) } else { @() }
    & $buildScript @buildArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed with exit code $LASTEXITCODE."
    }

    $x86Dll = Join-Path $repositoryRoot 'dist\x86\VSFilterMod.dll'
    $x64Dll = Join-Path $repositoryRoot 'dist\x64\VSFilterMod.dll'
    foreach ($dll in @($x86Dll, $x64Dll)) {
        if (-not (Test-Path -LiteralPath $dll -PathType Leaf)) {
            throw "Expected build output was not found: $dll"
        }
    }

    Copy-Item -LiteralPath $x86Dll -Destination (Join-Path $stagingRoot 'x86\VSFilterMod.dll')
    Copy-Item -LiteralPath $x64Dll -Destination (Join-Path $stagingRoot 'x64\VSFilterMod.dll')
    Copy-Item -LiteralPath (Join-Path $repositoryRoot 'README.md') -Destination $stagingRoot
    Copy-Item -LiteralPath (Join-Path $repositoryRoot 'README_PT-BR.md') -Destination $stagingRoot

    Compress-Archive -Path (Join-Path $stagingRoot '*') -DestinationPath $archivePath -CompressionLevel Optimal
    $hash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    [System.IO.File]::WriteAllText($checksumPath, "$hash  $archiveName`n", [System.Text.Encoding]::ASCII)

    Write-Host "Package:  $archivePath"
    Write-Host "SHA-256: $hash"
    Write-Host "Checksum: $checksumPath"
}
finally {
    $resolvedStaging = [System.IO.Path]::GetFullPath($stagingRoot)
    $expectedPrefix = $temporaryRoot.TrimEnd('\') + '\VSFilterMod-package-'
    if ((Test-Path -LiteralPath $resolvedStaging) -and $resolvedStaging.StartsWith($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        Remove-Item -LiteralPath $resolvedStaging -Recurse -Force
    }
}
