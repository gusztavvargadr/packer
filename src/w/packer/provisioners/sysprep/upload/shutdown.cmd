sc.exe config winrm start= disabled

mkdir C:\Windows\Setup\Scripts
copy A:\Autounattend.xml C:\Windows\Setup
copy A:\SetupComplete.cmd C:\Windows\Setup\Scripts

C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /quiet /quit /unattend:C:\Windows\Setup\Autounattend.xml

shutdown.exe /s /t 10
