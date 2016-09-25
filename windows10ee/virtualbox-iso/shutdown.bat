echo "Uninstalling Chef Client"
cuninst -y chef-client

echo "Disabling WinRM"
netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block

echo "Executing Sysprep"
copy A:\Autounattend.sysprep.xml C:\Windows
mkdir C:\Windows\Setup\Scripts
copy A:\Autounattend.sysprep.bat C:\Windows\Setup\Scripts\SetupComplete.cmd

C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /quiet /quit /unattend:C:\Windows\Autounattend.sysprep.xml

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OOBE" /v UnattendCreatedUser /d 1 /t REG_DWORD /f /reg:64

shutdown /s /t 1
