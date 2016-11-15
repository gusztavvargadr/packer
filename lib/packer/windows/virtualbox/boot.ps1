Write-Host "Extracting cookbooks"
7z x A:\cookbooks.tar.gz -o"C:\tmp\chef"
7z x C:\tmp\chef\cookbooks.tar -o"C:\tmp\chef"
