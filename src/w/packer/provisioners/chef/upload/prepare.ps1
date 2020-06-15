Write-Host "Install Chef Client"
choco install chef-client --confirm --version 16.1.16 --prerelease
[Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "Machine")

Write-Host "Install 7zip"
choco install 7zip.portable -y --version 19.0

Write-Host "Prepare cookbooks"
7z x C:\tmp\packer\chef-upload\cookbooks.tar.gz -o"C:\tmp\packer\chef-upload" -aoa
7z x C:\tmp\packer\chef-upload\cookbooks.tar -o"C:\tmp\packer\chef-upload" -aoa
