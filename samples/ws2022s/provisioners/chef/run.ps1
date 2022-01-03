Write-Host "Configure PowerShell"
$ProgressPreference = 'SilentlyContinue'
cd $env:PKR_CWD

cd policies
chef-client --local-mode --named-run-list $env:PKR_CHEF_NAMED_RUN_LIST
