$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
cd $env:PKR_CHEF_DIR

chef-client --local-mode --named-run-list $env:PKR_CHEF_NAMED_RUN_LIST
