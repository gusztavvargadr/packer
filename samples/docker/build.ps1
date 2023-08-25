$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$scriptDirectory = $PSScriptRoot

& "$($scriptDirectory)/../../src/windows/build.ps1" @args
