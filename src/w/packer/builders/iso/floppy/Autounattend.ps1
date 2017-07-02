Write-Host "Installing Chocolatey"
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

Write-Host "Installing PowerShell"
choco install powershell -y

Write-Host "Configuring network connections"
reg add "HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff"

$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$connections = $networkListManager.GetNetworkConnections()

$connections |foreach {
	Write-Host $_.GetNetwork().GetName()"category was previously set to"$_.GetNetwork().GetCategory()
	$_.GetNetwork().SetCategory(1)
	Write-Host $_.GetNetwork().GetName()"changed to category"$_.GetNetwork().GetCategory()
}

Write-Host "Setting password to never expire"
wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE

Write-Host "Configuring security zones"
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1806 /d 0 /t REG_DWORD /f /reg:64

Write-Host "Configuring WinRM"
winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

$certificate = New-SelfSignedCertificate -DnsName packer -CertStoreLocation Cert:\LocalMachine\My
winrm create winrm/config/listener?Address=*+Transport=HTTPS "@{Hostname=`"packer`";CertificateThumbprint=`"$($certificate.Thumbprint)`"}"
netsh advfirewall firewall add rule name="WinRM-HTTPS" dir=in localport=5986 protocol=TCP action=allow

net stop winrm
sc.exe config winrm start= auto

Write-Host "Shutting Down"
shutdown /r /t 10
