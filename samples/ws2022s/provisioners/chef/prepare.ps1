Write-Host "Configure PowerShell"
$ProgressPreference = 'SilentlyContinue'
cd $env:PKR_CWD

Write-Host "Install Chef Client"
. { Invoke-WebRequest -useb https://omnitruck.chef.io/install.ps1 } | Invoke-Expression; install -project chef -version 17.8.25
[Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "Machine")

Write-Host "Install Chocolatey"
$env:chocolateyVersion = '0.11.3'
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

choco install 7zip.portable --confirm

cd policies
7z x *.tgz
7z x *.tar
rm *.tar
rm *.tgz

# Write-Host "Install OpenSSH"
# netsh advfirewall firewall add rule name="OpenSSH-Install" dir=in localport=22 protocol=TCP action=block
# choco install openssh -y --version 8.0.0.1 -params '"/SSHServerFeature"' # /PathSpecsToProbeForShellEXEString:$env:windir\system32\windowspowershell\v1.0\powershell.exe"'
# net stop sshd
# netsh advfirewall firewall delete rule name="OpenSSH-Install"

# Write-Host "Configure OpenSSH"
# $sshd_config = "$($env:ProgramData)\ssh\sshd_config"
# (Get-Content $sshd_config).Replace("Match Group administrators", "# Match Group administrators") | Set-Content $sshd_config
# (Get-Content $sshd_config).Replace("AuthorizedKeysFile", "# AuthorizedKeysFile") | Set-Content $sshd_config
# net start sshd
