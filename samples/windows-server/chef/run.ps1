$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

If ((Get-Command "chef-client" -ErrorAction Ignore).Count -eq 0) {
  . { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chef -version 18.2.7
  [Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "Machine")
}

cd C:/Windows/Temp/chef
C:/opscode/chef/bin/chef-client.bat --local-mode
