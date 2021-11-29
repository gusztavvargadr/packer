mkdir -Force C:/Windows/Temp/chef

Write-Host "Install Chef Client"
. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chef -version 17.7.29
[Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "Machine")
