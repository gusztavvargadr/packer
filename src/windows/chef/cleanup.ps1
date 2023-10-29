$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$app = Get-WmiObject -Class Win32_Product | Where-Object -Property Name -Match "Chef Infra Client"
$app.Uninstall()

Optimize-Volume -DriveLetter C -Analyze -Defrag

sdelete -accepteula -nobanner -q -z C:
