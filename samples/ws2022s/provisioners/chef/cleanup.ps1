Write-Host "Configure PowerShell"
$ProgressPreference = 'SilentlyContinue'
cd $env:PKR_CWD

rm -Recurse -Force *
