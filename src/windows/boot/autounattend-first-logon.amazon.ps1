<powershell>

Write-Host "Configure PowerShell"
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

net user Administrator Packer42-
wmic useraccount where "name='Administrator'" set PasswordExpires=FALSE

Write-Host "Install Chocolatey"
$env:chocolateyVersion = '2.4.3'
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

Write-Host "Install OpenSSH"
netsh advfirewall firewall add rule name="OpenSSH-Install" dir=in localport=22 protocol=TCP action=block
choco install openssh -y --version 8.0.0.1 -params '"/SSHServerFeature"' # /PathSpecsToProbeForShellEXEString:$env:windir\system32\windowspowershell\v1.0\powershell.exe"'
net stop sshd
netsh advfirewall firewall delete rule name="OpenSSH-Install"

mkdir -Force C:/Users/Administrator/.ssh
rm -Force C:/Users/Administrator/.ssh/authorized_keys
Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key -OutFile C:/Users/Administrator/.ssh/authorized_keys

Write-Host "Configure OpenSSH"
$sshd_config = "$($env:ProgramData)\ssh\sshd_config"
(Get-Content $sshd_config).Replace("Match Group administrators", "# Match Group administrators") | Set-Content $sshd_config
(Get-Content $sshd_config).Replace("AuthorizedKeysFile", "# AuthorizedKeysFile") | Set-Content $sshd_config
net start sshd
sc.exe config sshd start= auto

</powershell>
