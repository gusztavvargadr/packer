echo "Uninstalling Chef Client"
cuninst -y chef-client

echo "Disabling WinRM"
netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block

echo "Executing Sysprep"
copy A:\Autounattend.sysprep.xml C:\Windows
mkdir C:\Windows\Setup\Scripts
copy A:\Autounattend.sysprep.bat C:\Windows\Setup\Scripts\SetupComplete.cmd

C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /quiet /shutdown /unattend:C:\Windows\Autounattend.sysprep.xml
