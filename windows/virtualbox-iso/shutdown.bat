@echo off

timeout /t 10 /nobreak
cuninst -y chef-client
timeout /t 10 /nobreak
rmdir /s /q C:\opscode
rmdir /s /q C:\tmp

netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block

copy A:\Autounattend.sysprep.xml C:\Windows
mkdir C:\Windows\Setup\Scripts
copy A:\Autounattend.sysprep.bat C:\Windows\Setup\Scripts\SetupComplete.cmd

A:\sysprep.bat
