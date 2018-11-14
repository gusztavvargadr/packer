Set-ExecutionPolicy RemoteSigned -Force

Write-Host "Install Chocolatey"
$env:chocolateyVersion = '0.10.11'
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Host "Install Chef Client"
choco install chef-client -y --version 14.3.37

Write-Host "Install 7zip"
choco install 7zip.portable -y --version 18.5

Write-Host "Install sdelete"
choco install sdelete -y --version 2.01

Write-Host "Install OpenSSH"
netsh advfirewall firewall add rule name="Autounattend SSH" dir=in localport=22 protocol=TCP action=block
# choco install openssh -y --version 7.7.2.1 -params '"/SSHServerFeature /PathSpecsToProbeForShellEXEString:$env:windir\system32\windowspowershell\v1.0\powershell.exe"'
choco install openssh -y --version 7.7.2.1 -params '"/SSHServerFeature"'
net stop sshd
netsh advfirewall firewall delete rule name="Autounattend SSH"

Write-Host "Configure network profiles"
Get-NetConnectionProfile | ForEach-Object { Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private }

Write-Host "Configure WinRM"
netsh advfirewall firewall add rule name="Autounattend WinRM-HTTP" dir=in localport=5985 protocol=TCP action=block

winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow
sc.exe config winrm start= auto

net stop winrm
netsh advfirewall firewall delete rule name="Autounattend WinRM-HTTP"

Write-Host "Disable Windows Updates"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /d 1 /t REG_DWORD /f /reg:64
sc.exe config wuauserv start= disabled

Write-Host "Disable Windows Store Updates"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /d 2 /t REG_DWORD /f /reg:64

Write-Host "Disable Maintenance"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f

Write-Host "Disable Windows Defender"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f

Write-Host "Disable UAC"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f

# TODO move to sysprep
Write-Host "Enable Remote Desktop"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
netsh advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow

Write-Host "Shut down"
shutdown /r /t 10
