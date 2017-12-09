Write-Host "Disable firewall"
netsh advfirewall set allprofiles state off

Write-Host "Configure security zones"
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1806 /d 0 /t REG_DWORD /f /reg:64

Write-Host "Install Chocolatey"
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Host "Install 7zip"
choco install 7zip.portable -y

Write-Host "Install Chef Client"
choco install chef-client -y --version 12.8.1.1

Write-Host "Extracting cookbooks"
7z x C:\packer-chef\cookbooks.tar.gz -o"C:\packer-chef" -aoa
7z x C:\packer-chef\cookbooks.tar -o"C:\packer-chef" -aoa
