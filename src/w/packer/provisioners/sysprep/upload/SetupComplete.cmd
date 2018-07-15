sc.exe config winrm start= auto
net start winrm

wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE
