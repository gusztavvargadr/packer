$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

mkdir -Force C:/Windows/Temp/chef

If ((Get-Command "C:/opscode/chef/bin/chef-client.bat" -ErrorAction Ignore).Count -eq 0) {
  . { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chef -version 18.3.0
}
C:/opscode/chef/bin/chef-client.bat --version
