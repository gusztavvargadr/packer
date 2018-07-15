@REM This script is called during the last phase of the Sysprep Specialize operation.  
@REM Re-enable RDP connections. 
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

sc.exe config winrm start= auto
net start winrm
