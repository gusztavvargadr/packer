Write-Host "Installing Chef Client"
choco install chef-client -y --version 12.14.77

Write-Host "Installing 7zip"
choco install 7zip.portable -y

Write-Host "Extracting cookbooks"
7z x C:\packer-chef\cookbooks.tar.gz -o"C:\packer-chef" -aoa
7z x C:\packer-chef\cookbooks.tar -o"C:\packer-chef" -aoa
