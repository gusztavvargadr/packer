Set-LocalUser -Name vagrant -PasswordNeverExpires $true

sc.exe config winrm start= auto
net start winrm

Write-Host "Configure OpenSSH"
mkdir -Force C:/Users/vagrant/.ssh
cp C:/Windows/Temp/packer/vagrant.pub C:/Users/vagrant/.ssh/authorized_keys

sc.exe config sshd start= auto
net start sshd
