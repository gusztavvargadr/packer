
Write-Host "Install Chef Client"
choco install chef-client -y --version 15.4.45
[Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "Machine")

Write-Host "Install 7zip"
choco install 7zip.portable -y --version 19.0

Write-Host "Prepare cookbooks"
7z x C:\tmp\packer\chef-upload\cookbooks.tar.gz -o"C:\tmp\packer\chef-upload" -aoa
7z x C:\tmp\packer\chef-upload\cookbooks.tar -o"C:\tmp\packer\chef-upload" -aoa
