wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE

sc.exe config winrm start= auto
net start winrm

Write-Host "Configure OpenSSH"
mkdir -Force C:/Users/vagrant/.ssh
cp C:/Windows/Setup/packer/vagrant.pub C:/Users/vagrant/.ssh/authorized_keys

sc.exe config sshd start= auto
net start sshd

net localgroup docker-users vagrant /add
