$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

cd C:/Windows/Temp/chef

$env:CHEF_LICENSE = "accept-silent"

chef-client --local-mode
