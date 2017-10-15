Write-Host "Cleaning up cookbooks"
Remove-Item -Recurse -Force C:\packer-chef
Remove-Item -Recurse -Force /tmp/packer-chef-solo
