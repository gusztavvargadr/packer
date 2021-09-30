Write-Host "Clean up"
Remove-Item -Recurse -Force C:/Windows/Temp/chef

# Remove chef client, or it will cause problems later when kitchen tries to install cinc.
$chef_client = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name.StartsWith("Chef Infra")}
$chef_client.Uninstall()
