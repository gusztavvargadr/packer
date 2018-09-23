mkdir -Force C:/Users/Administrator/.ssh
rm -Force C:/Users/Administrator/.ssh/authorized_keys
Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key -OutFile C:/Users/Administrator/.ssh/authorized_keys

sc.exe config sshd start= auto
net start sshd
