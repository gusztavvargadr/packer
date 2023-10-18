mkdir -Force C:/Windows/Temp/chef

If ((Get-Command "chef-client" -ErrorAction Ignore).Count -gt 0) {
  Return
}

Write-Host "Install Chef Client"
. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chef -version 18.3.0
[Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "Machine")
