sc.exe config sshd start= disabled

Invoke-WebRequest -Uri https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub -OutFile C:/Windows/Setup/packer/vagrant.pub

C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /quiet /shutdown /unattend:C:\Windows\Setup\packer\Autounattend.xml

REM powershell -Command "Optimize-Volume -DriveLetter C"
REM sdelete -z C:
