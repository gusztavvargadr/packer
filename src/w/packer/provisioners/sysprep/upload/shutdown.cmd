netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block
netsh advfirewall firewall set rule name="WinRM-HTTPS" new action=block

mkdir C:\Windows\Setup\Scripts
copy A:\Autounattend.xml C:\Windows\Setup
copy A:\SetupComplete.cmd C:\Windows\Setup\Scripts

C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /quiet /quit /unattend:C:\Windows\Setup\Autounattend.xml
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OOBE" /v UnattendCreatedUser /d 1 /t REG_DWORD /f /reg:64

shutdown.exe /s /t 10
