<powershell>

Set-ExecutionPolicy RemoteSigned -Force

Write-Host "Configure network profiles"
Get-NetConnectionProfile | ForEach-Object { Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private }

Write-Host "Configure WinRM"
winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

net stop winrm
sc.exe config winrm start= auto

Write-Host "Set password to never expire"
wmic useraccount where "name='Administrator'" set PasswordExpires=FALSE

Write-Host "Shut down"
shutdown /r /t 10

</powershell>
