netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block

mkdir C:\Windows\Setup\Scripts
cd /Users/vagrant/Downloads/packer
copy Autounattend.xml C:\Windows\Setup
copy Autounattend.cmd C:\Windows\Setup\Scripts\SetupComplete.cmd

C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /quiet /quit /unattend:C:\Windows\Setup\Autounattend.xml
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OOBE" /v UnattendCreatedUser /d 1 /t REG_DWORD /f /reg:64

shutdown /s /t 10
