$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

@(
  "$env:localappdata\temp\*",
  "$env:windir\logs",
  "$env:windir\panther",
  "$env:windir\Temp\\Chef",
  "$env:programdata\Microsoft\Windows Defender\Scans\*"
) | % {
  Write-Host "Removing $_"
  try {
    Takeown /d Y /R /f $_
    Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
    Remove-Item $_ -Recurse -Force | Out-Null
  } catch { $global:error.RemoveAt(0) }
}

$app = Get-WmiObject -Class Win32_Product | Where-Object -Property Name -Match "Chef Infra Client"
$app.Uninstall()

Optimize-Volume -DriveLetter C -Analyze -Defrag

sdelete -accepteula -nobanner -z C:
