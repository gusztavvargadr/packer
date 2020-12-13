#ps1_sysnative

# PowerShell
$ErrorActionPreference = "Stop"

Set-ExecutionPolicy RemoteSigned -Force
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Windows
Set-MpPreference -DisableRealtimeMonitoring $True -ExclusionPath "C:\"

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /d 1 /t REG_DWORD /f /reg:64
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /d 2 /t REG_DWORD /f /reg:64

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f

netsh advfirewall set allprofiles settings inboundusernotification enable

# Chocolatey
$env:chocolateyVersion = '0.10.15'
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
choco config set cacheLocation C:\tmp\chocolatey

# Chef Client
. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chef -version 16.7.61
[Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "User")
[Environment]::SetEnvironmentVariable("AZP_AGENT_CHEF_CLIENT", "16.7.61", "User")

# 7Zip
choco install -y 7zip.portable

# Workstation
choco install -y googlechrome
choco install -y conemu
choco install -y far
choco install -y treesizefree
choco install -y vscode
choco install -y beyondcompare

# AZP Agent
wget https://vstsagentpackage.azureedge.net/agent/2.179.0/vsts-agent-win-x64-2.179.0.zip -OutFile vsts-agent.zip
[Environment]::SetEnvironmentVariable("VSTS_AGENT_INPUT_URL", "https://dev.azure.com/gusztavvargadr/", "User")
[Environment]::SetEnvironmentVariable("VSTS_AGENT_INPUT_AUTH", "pat", "User")
# [Environment]::SetEnvironmentVariable("VSTS_AGENT_INPUT_TOKEN", "Token42-", "User")
## TODO Configure agents

# Development
choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /NoAutoCrlf /NoShellIntegration /SChannel'"
choco install -y poshgit
choco install -y dotnetcore-sdk
& 'C:\Program Files\dotnet\dotnet.exe' tool install Cake.Tool --global

choco install -y vagrant --version 2.2.14 --ignore-package-exit-codes
[Environment]::SetEnvironmentVariable("AZP_AGENT_VAGRANT", "2.2.14", "User")

# C:\HashiCorp\Vagrant\embedded\gems\2.2.14\gems\vagrant-2.2.14\bin\vagrant
# Encoding.default_external = Encoding.find('Windows-1250')
# Encoding.default_internal = Encoding.find('Windows-1250')

Get-WindowsOptionalFeature -Online | Where { $_.FeatureName -match "hyper" } | Where { $_.State -ne "Enabled" } | ForEach { Enable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -All -NoRestart }
[Environment]::SetEnvironmentVariable("VAGRANT_PROVIDER_HYPERV_LINKED_CLONE", "false", "User")
[Environment]::SetEnvironmentVariable("VAGRANT_PROVIDER_HYPERV_VIRTUALIZATION", "true", "User")
[Environment]::SetEnvironmentVariable("VAGRANT_SYNCED_FOLDER_SMB_USERNAME", "Admin", "User")
# [Environment]::SetEnvironmentVariable("VAGRANT_SYNCED_FOLDER_SMB_PASSWORD", "Password42-", "User")
[Environment]::SetEnvironmentVariable("VAGRANT_PROVIDER_HYPERV_NETWORK_BRIDGE", "HyperVNAT", "User")
[Environment]::SetEnvironmentVariable("AZP_AGENT_HYPERV", "9.0", "User")
[Environment]::SetEnvironmentVariable("VAGRANT_DEFAULT_PROVIDER", "hyperv", "User")
## TODO DHCP

choco install -y virtualbox --version 6.1.16 --params "/ExtensionPack"
[Environment]::SetEnvironmentVariable("_AZP_AGENT_VIRTUALBOX", "6.1.16", "User")
# [Environment]::SetEnvironmentVariable("VAGRANT_DEFAULT_PROVIDER", "virtualbox", "User")

choco install -y docker-desktop --version 2.2.0.5
[Environment]::SetEnvironmentVariable("AZP_AGENT_DOCKER_LINUX", "19.03", "User")
[Environment]::SetEnvironmentVariable("_AZP_AGENT_DOCKER_WINDOWS", "19.03", "User")
# [Environment]::SetEnvironmentVariable("VAGRANT_DEFAULT_PROVIDER", "docker", "User")

choco install -y packer --version 1.6.4
[Environment]::SetEnvironmentVariable("PACKER_CACHE_DIR", "C:\Users\Admin\.packer\cache", "User")
[Environment]::SetEnvironmentVariable("PACKER_VAR_hyperv_switch_name", "HyperVNAT", "User")
[Environment]::SetEnvironmentVariable("AZP_AGENT_PACKER", "1.6.4", "User")
## TODO download ISOs

. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project chef-workstation -version 20.12.187
[Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "User")
[Environment]::SetEnvironmentVariable("KITCHEN_HYPERV_SWITCH", "HyperVNAT", "User")
[Environment]::SetEnvironmentVariable("AZP_AGENT_CHEF_WORKSTATION", "20.12.187", "User")
