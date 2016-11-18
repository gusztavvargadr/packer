timeout /t 10 /nobreak
rmdir /s /q C:\tmp

netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block

copy A:\sysprep.Autounattend.xml C:\Windows
mkdir C:\Windows\Setup\Scripts
copy A:\sysprep.install.bat C:\Windows\Setup\Scripts\SetupComplete.cmd

A:\sysprep.bat
