sc.exe config winrm start= disabled
sc.exe config sshd start= disabled

timeout 180
C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /quiet /shutdown /unattend:C:\Windows\Setup\packer\Autounattend.xml
