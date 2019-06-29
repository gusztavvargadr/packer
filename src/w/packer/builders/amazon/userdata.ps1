<powershell>

Set-ExecutionPolicy RemoteSigned -Force

Write-Host "Install Chocolatey"
$env:chocolateyVersion = '0.10.15'
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Host "Install OpenSSH"
netsh advfirewall firewall add rule name="Autounattend SSH" dir=in localport=22 protocol=TCP action=block

choco install openssh -y --version 8.0.0.1 -params '"/SSHServerFeature"' # /PathSpecsToProbeForShellEXEString:$env:windir\system32\windowspowershell\v1.0\powershell.exe"'

$sshd_config = "$($env:ProgramData)\ssh\sshd_config"
(Get-Content $sshd_config).Replace("Match Group administrators", "# Match Group administrators") | Set-Content $sshd_config
(Get-Content $sshd_config).Replace("AuthorizedKeysFile", "# AuthorizedKeysFile") | Set-Content $sshd_config

net stop sshd

netsh advfirewall firewall delete rule name="Autounattend SSH"

sc.exe config sshd start= auto

Write-Host "Configure SSH key"
mkdir -Force C:/Users/Administrator/.ssh
Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key -OutFile C:/Users/Administrator/.ssh/authorized_keys

Write-Host "Shut down"
shutdown /r /t 10

</powershell>
