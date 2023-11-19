$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

cd C:/Windows/Temp/chef

$runOptions = "--local-mode"

if (![string]::IsNullOrEmpty($env:CHEF_ATTRIBUTES)) {
  $runOptions = "$($runOptions) --json-attributes attributes.$($env:CHEF_ATTRIBUTES).json"
}

$env:CHEF_LICENSE = "accept-silent"
Invoke-Expression "C:/opscode/chef/bin/chef-client.bat $($runOptions)"
