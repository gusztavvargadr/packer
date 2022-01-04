$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Get-NetConnectionProfile | ForEach-Object { Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private }

netsh advfirewall firewall add rule name="WinRM-Install" dir=in localport=5985 protocol=TCP action=block

winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'

net stop winrm
netsh advfirewall firewall delete rule name="WinRM-Install"

netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow
net start winrm
