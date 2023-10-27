$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$scriptDirectory = $PSScriptRoot

& "$($scriptDirectory)/../src/ubuntu/build.ps1" @args
