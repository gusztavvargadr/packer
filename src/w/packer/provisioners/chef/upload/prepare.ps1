Write-Host "Install Chef Client"
. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chef -version 16.4.41
[Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "Machine")

Write-Host "Install 7zip"
choco install 7zip.portable -y

Write-Host "Prepare cookbooks"
7z x C:\tmp\packer\chef-upload\cookbooks.tar.gz -o"C:\tmp\packer\chef-upload" -aoa
7z x C:\tmp\packer\chef-upload\cookbooks.tar -o"C:\tmp\packer\chef-upload" -aoa
