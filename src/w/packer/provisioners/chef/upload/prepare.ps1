Write-Host "Prepare cookbooks"
7z x C:\tmp\packer\chef-upload\cookbooks.tar.gz -o"C:\tmp\packer\chef-upload" -aoa
7z x C:\tmp\packer\chef-upload\cookbooks.tar -o"C:\tmp\packer\chef-upload" -aoa
