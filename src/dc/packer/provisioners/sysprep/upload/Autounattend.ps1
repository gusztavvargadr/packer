wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE
net localgroup docker-users vagrant /add

mkdir -Force C:/Users/vagrant/.ssh
cp C:/Windows/Setup/packer/vagrant.pub -OutFile C:/Users/vagrant/.ssh/authorized_keys

sc.exe config sshd start= auto
net start sshd
