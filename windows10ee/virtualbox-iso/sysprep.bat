C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /quiet /quit /unattend:C:\Windows\Autounattend.sysprep.xml

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OOBE" /v UnattendCreatedUser /d 1 /t REG_DWORD /f /reg:64

shutdown /s /t 1
