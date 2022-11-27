Set-LocalUser -Name vagrant -PasswordNeverExpires $true

sc.exe config winrm start= auto
net start winrm
