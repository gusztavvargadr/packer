$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

cd C:/Windows/Temp/chef

chef-client --local-mode
