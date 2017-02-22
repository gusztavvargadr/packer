@REM Disable further Terminal Service (RDP) connections until re-enabled.
@REM RDP connections are then re-enabled by the SysprepSpecialize.cmd
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f

sc.exe config winrm start= disabled
