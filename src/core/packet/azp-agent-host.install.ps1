#ps1_sysnative

# PowerShell
Set-ExecutionPolicy RemoteSigned -Force
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# AZP Agent
wget https://vstsagentpackage.azureedge.net/agent/2.164.7/vsts-agent-win-x64-2.164.7.zip -OutFile vsts-agent.zip
[Environment]::SetEnvironmentVariable("VSTS_AGENT_INPUT_URL", "https://dev.azure.com/gusztavvargadr/", "User")
[Environment]::SetEnvironmentVariable("VSTS_AGENT_INPUT_AUTH", "pat", "User")
# [Environment]::SetEnvironmentVariable("VSTS_AGENT_INPUT_TOKEN", "Token42-", "User")
# TODO Configure agents

# Chef Client
choco install chef-client -y --version 15.7.32
[Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "User")
[Environment]::SetEnvironmentVariable("AZP_AGENT_CHEF", "client", "User")

choco install 7zip.portable -y --version 19.0

# Windows
Set-MpPreference -DisableRealtimeMonitoring $True -ExclusionPath "C:\"

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /d 1 /t REG_DWORD /f /reg:64
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /d 2 /t REG_DWORD /f /reg:64

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f
# TODO Firewall notify

# Workstation
choco install -y firefox
choco install -y conemu
choco install -y far
choco install -y treesizefree
choco install -y vscode
choco install -y beyondcompare

# Development
choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /NoAutoCrlf /NoShellIntegration'"
choco install -y poshgit
choco install -y dotnetcore-sdk --version=3.1.101
& 'C:\Program Files\dotnet\dotnet.exe' tool install Cake.Tool --global --version 0.35.0

choco install -y vagrant --version 2.2.7 --ignore-package-exit-codes
[Environment]::SetEnvironmentVariable("AZP_AGENT_VAGRANT", "%VAGRANT_DEFAULT_PROVIDER%", "User")

choco install -y chef-workstation --version 0.15.6
[Environment]::SetEnvironmentVariable("CHEF_LICENSE", "accept-silent", "User")
[Environment]::SetEnvironmentVariable("AZP_AGENT_CHEF", "workstation", "User")

# choco install -y docker-desktop

# choco install -y virtualbox --version 6.1.2.20200116
# [Environment]::SetEnvironmentVariable("VAGRANT_DEFAULT_PROVIDER", "virtualbox", "User")

# Get-WindowsOptionalFeature -Online | Where { $_.FeatureName -match "hyper" } | Where { $_.State -ne "Enabled" } | ForEach { Enable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -All -NoRestart }
# Get-WindowsOptionalFeature -Online | Where { $_.FeatureName -match "dhcp" } | Where { $_.State -ne "Enabled" } | ForEach { Enable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -All -NoRestart }
# New-VMSwitch -SwitchName HyperVNAT -SwitchType Internal
# New-NetIPAddress -IPAddress 192.168.238.1 -PrefixLength 24 -InterfaceAlias "vEthernet (HyperVNAT)"
# New-NetNat -Name HyperVNAT -InternalIPInterfaceAddressPrefix 192.168.238.0/24
## TODO Configure NAT external addresses
## TODO Configure DHCP
# [Environment]::SetEnvironmentVariable("VAGRANT_DEFAULT_PROVIDER", "hyperv", "User")
# [Environment]::SetEnvironmentVariable("VAGRANT_PROVIDER_HYPERV_LINKED_CLONE", "true", "User")
# [Environment]::SetEnvironmentVariable("VAGRANT_PROVIDER_HYPERV_VIRTUALIZATION", "true", "User")
# [Environment]::SetEnvironmentVariable("VAGRANT_SYNCED_FOLDER_SMB_USERNAME", "Admin", "User")
## [Environment]::SetEnvironmentVariable("VAGRANT_SYNCED_FOLDER_SMB_PASSWORD", "Password42-", "User")
# [Environment]::SetEnvironmentVariable("VAGRANT_PROVIDER_HYPERV_NETWORK_BRIDGE", "HyperVNAT", "User")

# Packer
choco install -y packer --version 1.4.3
[Environment]::SetEnvironmentVariable("AZP_AGENT_PACKER", "%AZP_AGENT_VAGRANT%", "User")
[Environment]::SetEnvironmentVariable("PACKER_CACHE_DIR", "C:\Users\Admin\.packer\cache", "User")
[Environment]::SetEnvironmentVariable("PACKER_VAR_hyperv_switch_name", "%VAGRANT_PROVIDER_HYPERV_NETWORK_BRIDGE%", "User")
