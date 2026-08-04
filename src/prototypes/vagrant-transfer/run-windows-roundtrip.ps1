[CmdletBinding()]
param(
  [string] $WorkDirectory = (Join-Path $PSScriptRoot "roundtrip-windows")
)

$ErrorActionPreference = "Stop"

$helperPath = Join-Path $PSScriptRoot "vagrant-transfer-windows-amd64.exe"
$helperChecksum = "bfadfbca805f461da4142103640aa8cd5c711bc7bfc3128e76642a4494ed302c"
$boxUrl = "https://vagrantcloud.com/gusztavvargadr/boxes/windows-11-25h2-enterprise/versions/2607.0.0/providers/hyperv/amd64/vagrant.box"
$boxChecksum = "bb044a55cf055b6b72db66f5842de73f276d0a034b57925b33405dfbf57caf41"

if (-not (Test-Path -LiteralPath $helperPath -PathType Leaf)) {
  throw "Copy vagrant-transfer-windows-amd64.exe beside this script before running it."
}

$actualHelperChecksum = (Get-FileHash -LiteralPath $helperPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualHelperChecksum -ne $helperChecksum) {
  throw "Helper checksum mismatch: $actualHelperChecksum"
}

New-Item -ItemType Directory -Force -Path $WorkDirectory | Out-Null
$sourceBoxPath = Join-Path $WorkDirectory "source.box"
$roundtripDirectory = Join-Path $WorkDirectory "roundtrip"
$logPath = Join-Path $WorkDirectory "roundtrip.log"

if (-not (Test-Path -LiteralPath $sourceBoxPath -PathType Leaf)) {
  & curl.exe -fL --retry 4 --retry-delay 5 --output $sourceBoxPath $boxUrl
  if ($LASTEXITCODE -ne 0) {
    throw "Box download failed with exit code $LASTEXITCODE"
  }
}

$actualBoxChecksum = (Get-FileHash -LiteralPath $sourceBoxPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualBoxChecksum -ne $boxChecksum) {
  throw "Source box checksum mismatch: $actualBoxChecksum"
}

$started = Get-Date
& $helperPath roundtrip $sourceBoxPath $roundtripDirectory 1.1.6 | Tee-Object -FilePath $logPath
if ($LASTEXITCODE -ne 0) {
  throw "Prototype failed with exit code $LASTEXITCODE"
}

$elapsed = (Get-Date) - $started
Write-Host "Elapsed: $elapsed"
Write-Host "Log: $logPath"
