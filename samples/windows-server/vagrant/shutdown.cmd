powershell -C "Get-AppxPackage -Name ""*OneDriveSync*"" | Remove-AppxPackage"

sc.exe config winrm start= disabled
sc.exe config sshd start= disabled

C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /quiet /shutdown /unattend:C:\Windows\Temp\packer\Autounattend.xml
