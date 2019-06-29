wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE

Write-Host "Configure OpenSSH"
mkdir -Force C:/Users/vagrant/.ssh
cp C:/Windows/Setup/packer/vagrant.pub C:/Users/vagrant/.ssh/authorized_keys

sc.exe config sshd start= auto

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

Write-Host "Shut down"
shutdown /r /t 10
