Set-ExecutionPolicy RemoteSigned -Force

Write-Host "Install Chocolatey"
$env:chocolateyVersion = '0.10.15'
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Host "Configure WinRM"
netsh advfirewall firewall add rule name="Autounattend WinRM-HTTP" dir=in localport=5985 protocol=TCP action=block

Get-NetConnectionProfile | ForEach-Object { Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private }

winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

net stop winrm

netsh advfirewall firewall delete rule name="Autounattend WinRM-HTTP"
sc.exe config winrm start= auto

Write-Host "Install OpenSSH"
netsh advfirewall firewall add rule name="Autounattend SSH" dir=in localport=22 protocol=TCP action=block

choco install openssh -y --version 8.0.0.1 -params '"/SSHServerFeature"' # /PathSpecsToProbeForShellEXEString:$env:windir\system32\windowspowershell\v1.0\powershell.exe"'

$sshd_config = "$($env:ProgramData)\ssh\sshd_config"
(Get-Content $sshd_config).Replace("Match Group administrators", "# Match Group administrators") | Set-Content $sshd_config
(Get-Content $sshd_config).Replace("AuthorizedKeysFile", "# AuthorizedKeysFile") | Set-Content $sshd_config

net stop sshd

netsh advfirewall firewall delete rule name="Autounattend SSH"
sc.exe config sshd start= auto

Write-Host "Shut down"
shutdown /r /t 10
