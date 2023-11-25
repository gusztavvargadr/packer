$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

mkdir -Force C:/Windows/Temp/chef

If ((Get-Command "C:/opscode/chef/bin/chef-client.bat" -ErrorAction Ignore).Count -eq 0) {
  . { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chef -version 18.3.0
}
C:/opscode/chef/bin/chef-client.bat --version

If ((Get-Command "choco" -ErrorAction Ignore).Count -eq 0) {
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
choco --version
