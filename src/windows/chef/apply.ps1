$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

cd C:/Windows/Temp/chef

# Chef 18.10.17 races while exporting Windows certificate keys during parallel cookbook sync.
$runOptions = "--local-mode --config-option cookbook_sync_threads=1"

if (![string]::IsNullOrEmpty($env:CHEF_ATTRIBUTES)) {
  $runOptions = "$($runOptions) --json-attributes attributes.$($env:CHEF_ATTRIBUTES).json"
}

$env:CHEF_LICENSE = "accept-silent"
Invoke-Expression "C:/opscode/chef/bin/chef-client.bat $($runOptions)"
