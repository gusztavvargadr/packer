windows_defender_exclusion '' do
  paths ['C:\\']
  action :add
end

windows_uac '' do
  enable_uac false
  action :configure
  notifies :request_reboot, 'reboot[gusztavvargadr_packer_windows]', :immediately
end

registry_key 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System' do
  values [{
    name: 'LocalAccountTokenFilterPolicy',
    type: :dword,
    data: 1,
  }]
  recursive true
  action :create
end

powershell_script 'Configure and validate power policy' do
  code <<-EOH
    function Invoke-PowerCfg {
      param([string[]] $PowerArguments)

      $output = & powercfg.exe @PowerArguments 2>&1
      if ($LASTEXITCODE -ne 0) {
        throw "powercfg $($PowerArguments -join ' ') failed with exit code $($LASTEXITCODE): $($output -join ' ')"
      }

      return $output
    }

    Add-Type @'
    using System;
    using System.Runtime.InteropServices;

    public static class PowerPolicyNativeMethods
    {
        [DllImport("powrprof.dll")]
        public static extern UInt32 PowerGetActiveScheme(IntPtr userRootPowerKey, out IntPtr activePolicyGuid);

        [DllImport("powrprof.dll")]
        public static extern UInt32 PowerReadACValueIndex(IntPtr rootPowerKey, ref Guid schemeGuid,
            ref Guid subgroupGuid, ref Guid settingGuid, out UInt32 valueIndex);

        [DllImport("powrprof.dll")]
        public static extern UInt32 PowerReadDCValueIndex(IntPtr rootPowerKey, ref Guid schemeGuid,
            ref Guid subgroupGuid, ref Guid settingGuid, out UInt32 valueIndex);

        [DllImport("kernel32.dll")]
        public static extern IntPtr LocalFree(IntPtr memory);
    }
'@

    function Get-ActivePowerScheme {
      $schemePointer = [IntPtr]::Zero
      $result = [PowerPolicyNativeMethods]::PowerGetActiveScheme([IntPtr]::Zero, [ref] $schemePointer)
      if ($result -ne 0) {
        throw "Unable to read the active power scheme (error code $result)."
      }

      try {
        return [Guid] [Runtime.InteropServices.Marshal]::PtrToStructure($schemePointer, [type] [Guid])
      } finally {
        [void] [PowerPolicyNativeMethods]::LocalFree($schemePointer)
      }
    }

    function Get-PowerSettingValue {
      param(
        [Guid] $Scheme,
        [Guid] $Subgroup,
        [Guid] $Setting,
        [ValidateSet('AC', 'DC')] [string] $PowerSource
      )

      [UInt32] $value = 0
      if ($PowerSource -eq 'AC') {
        $result = [PowerPolicyNativeMethods]::PowerReadACValueIndex(
          [IntPtr]::Zero, [ref] $Scheme, [ref] $Subgroup, [ref] $Setting, [ref] $value
        )
      } else {
        $result = [PowerPolicyNativeMethods]::PowerReadDCValueIndex(
          [IntPtr]::Zero, [ref] $Scheme, [ref] $Subgroup, [ref] $Setting, [ref] $value
        )
      }

      if ($result -ne 0) {
        throw "Unable to read the $PowerSource power setting '$Setting' (error code $result)."
      }

      return $value
    }

    $highPerformanceScheme = [Guid] '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
    $sleepSubgroup = [Guid] '238c9fa8-0aad-41ed-83f4-97be242c8f20'
    $sleepTimeout = [Guid] '29f6c1db-86da-48c5-9fdb-f2b67b1f44da'
    $hibernateTimeout = [Guid] '9d7815a6-7ee4-497e-8888-515a05f02364'

    $availableSchemes = Invoke-PowerCfg @('/list')
    if (($availableSchemes -join "`n") -notmatch $highPerformanceScheme) {
      throw "High performance power scheme '$highPerformanceScheme' is unavailable."
    }

    Invoke-PowerCfg @('/setactive', $highPerformanceScheme) | Out-Null
    Invoke-PowerCfg @('/setacvalueindex', $highPerformanceScheme, $sleepSubgroup, $sleepTimeout, 0) | Out-Null
    Invoke-PowerCfg @('/setdcvalueindex', $highPerformanceScheme, $sleepSubgroup, $sleepTimeout, 0) | Out-Null
    Invoke-PowerCfg @('/setacvalueindex', $highPerformanceScheme, $sleepSubgroup, $hibernateTimeout, 0) | Out-Null
    Invoke-PowerCfg @('/setdcvalueindex', $highPerformanceScheme, $sleepSubgroup, $hibernateTimeout, 0) | Out-Null
    Invoke-PowerCfg @('/setactive', $highPerformanceScheme) | Out-Null

    $activeScheme = Get-ActivePowerScheme
    if ($activeScheme -ne $highPerformanceScheme) {
      throw "Power policy validation failed: active scheme is '$activeScheme'; expected High performance '$highPerformanceScheme'."
    }

    $sleepAc = Get-PowerSettingValue $activeScheme $sleepSubgroup $sleepTimeout 'AC'
    $sleepDc = Get-PowerSettingValue $activeScheme $sleepSubgroup $sleepTimeout 'DC'
    $hibernateAc = Get-PowerSettingValue $activeScheme $sleepSubgroup $hibernateTimeout 'AC'
    $hibernateDc = Get-PowerSettingValue $activeScheme $sleepSubgroup $hibernateTimeout 'DC'

    $timeouts = [ordered] @{
      'sleep-ac' = $sleepAc
      'sleep-dc' = $sleepDc
      'hibernate-ac' = $hibernateAc
      'hibernate-dc' = $hibernateDc
    }
    $invalidTimeouts = @($timeouts.GetEnumerator() | Where-Object { $_.Value -ne 0 })
    if ($invalidTimeouts.Count -ne 0) {
      $details = $invalidTimeouts | ForEach-Object { "$($_.Key)=$($_.Value)" }
      throw "Power policy validation failed: $($details -join ', '); expected every timeout to be 0 (Never)."
    }

    Write-Output "Power policy: scheme=High performance ($activeScheme); sleep-ac=$sleepAc; sleep-dc=$sleepDc; hibernate-ac=$hibernateAc; hibernate-dc=$hibernateDc"
  EOH
  action :run
end

gusztavvargadr_windows_update '' do
  action :initialize
end

registry_key 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Schedule\\Maintenance' do
  values [{
    name: 'MaintenanceDisabled',
    type: :dword,
    data: 1,
  }]
  recursive true
  action :create
end

registry_key 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server' do
  values [{
    name: 'fDenyTSConnections',
    type: :dword,
    data: 0,
  }]
  recursive true
  action :create
end

windows_firewall_rule 'Remote Desktop' do
  direction :inbound
  local_port '3389'
  protocol 'TCP'
  firewall_action :allow
  action :create
end

sdelete_archive_source = 'https://download.sysinternals.com/files/SDelete.zip'
sdelete_archive_target = "#{Chef::Config['file_cache_path']}/SDelete.zip"
sdelete_archive_destination = "#{Chef::Config['file_cache_path']}/sdelete"
sdelete_executable_source = "file:///#{Chef::Config['file_cache_path']}/sdelete/sdelete64.exe"
sdelete_executable_target = "#{powershell_out('$env:SystemRoot').stdout.strip}/System32/sdelete.exe"

remote_file sdelete_archive_target do
  source sdelete_archive_source
  action :create
end

archive_file sdelete_archive_target do
  destination sdelete_archive_destination
  action :extract
end

remote_file sdelete_executable_target do
  source sdelete_executable_source
  action :create
end

configured_vbox_guest_additions_reconcile = ENV.fetch('VIRTUALBOX_GUEST_ADDITIONS_RECONCILE', 'false') == 'true'

if vbox? || configured_vbox_guest_additions_reconcile
  installed_vbox_version = (powershell_out('& "C:/Program Files/Oracle/VirtualBox Guest Additions/VBoxGuest/VBoxControl.exe" -v').stdout rescue '').strip
  host_vbox_version = nil
  vbox_guest_additions_current = installed_vbox_version.include?('7.')

  if configured_vbox_guest_additions_reconcile
    host_vbox_version = powershell_out('(Get-Content "$env:HOME/.vbox_version").Trim()').stdout.strip
    vbox_guest_additions_current = installed_vbox_version.sub(/r.*\z/, '') == host_vbox_version
  end

  unless vbox_guest_additions_current
    host_vbox_version ||= powershell_out('(Get-Content "$env:HOME/.vbox_version").Trim()').stdout.strip
    vbox_guest_additions_path = "#{Chef::Config['file_cache_path']}/VBoxGuestAdditions.iso"
    vbox_guest_additions_source = "https://download.virtualbox.org/virtualbox/#{host_vbox_version}/VBoxGuestAdditions_#{host_vbox_version}.iso"

    remote_file vbox_guest_additions_path do
      source vbox_guest_additions_source
      action :create
    end

    gusztavvargadr_windows_iso '' do
      iso_path vbox_guest_additions_path
      iso_drive_letter 'Z'
      action :mount
    end

    powershell_script 'Install VirtualBox certificates' do
      code <<-EOH
        Start-Process "VBoxCertUtil.exe" "add-trusted-publisher vbox*.cer --root vbox*.cer" -Wait
      EOH
      cwd 'Z:/cert'
      action :run
    end

    powershell_script 'Install VirtualBox Guest Additions' do
      code <<-EOH
        Start-Process "VBoxWindowsAdditions.exe" "/S" -Wait
      EOH
      cwd 'Z:'
      action :run
      notifies :request_reboot, 'reboot[gusztavvargadr_packer_windows]', :immediately
    end
 
    gusztavvargadr_windows_iso '' do
      iso_path vbox_guest_additions_path
      iso_drive_letter 'Z'
      action :dismount
    end
  end
end

if vmware?
  vmware_tools_path = 'C:/Program Files/VMware/VMware Tools/vmtoolsd.exe'
  vmware_version = (powershell_out("(Get-Item '#{vmware_tools_path}').VersionInfo.FileVersion").stdout rescue '').strip
  configured_vmware_tools_version = ENV.fetch('VMWARE_TOOLS_VERSION', '')
  configured_vmware_tools_source = ENV.fetch('VMWARE_TOOLS_SOURCE', '')

  vmware_tools_version_matches = vmware_version.include?('13.')
  unless configured_vmware_tools_version.empty?
    vmware_tools_version_matches = vmware_version[/\A\d+\.\d+\.\d+/] == configured_vmware_tools_version
  end

  unless vmware_tools_version_matches
    vmware_tools_source = configured_vmware_tools_source
    if vmware_tools_source.empty?
      vmware_tools_source = 'https://packages-prod.broadcom.com/tools/releases/13.1.0/windows/x64/VMware-tools-13.1.0-25218885-x64.exe'
    end
    vmware_tools_target = "#{Chef::Config['file_cache_path']}/VMware-tools.exe"

    remote_file vmware_tools_target do
      source vmware_tools_source
      action :create
    end

    powershell_script 'Install VMware Tools' do
      code <<-EOH
        Start-Process "#{vmware_tools_target}" "/S /v /qn REBOOT=R ADDLOCAL=ALL" -Wait
      EOH
      action :run
      notifies :request_reboot, 'reboot[gusztavvargadr_packer_windows]', :immediately
    end
  end
end

if kvm?
  qemu_guest_agent_path = "C:/Program Files/Qemu-ga/qemu-ga.exe"
  unless ::File.exist?(qemu_guest_agent_path)
    virtio_iso_source = 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso'
    virtio_iso_target = "#{Chef::Config['file_cache_path']}/virtio-win.iso"
    virtio_iso_drive_letter = 'Z'

    remote_file virtio_iso_target do
      source virtio_iso_source
      action :create
    end

    gusztavvargadr_windows_iso '' do
      iso_path virtio_iso_target
      iso_drive_letter virtio_iso_drive_letter
      action :mount
    end

    powershell_script 'Install VirtIO Guest Tools' do
      code <<-EOH
        Start-Process "virtio-win-guest-tools.exe" "/install /quiet /norestart" -Wait
      EOH
      cwd 'Z:'
      action :run
      notifies :request_reboot, 'reboot[gusztavvargadr_packer_windows]', :immediately
    end

    gusztavvargadr_windows_iso '' do
      iso_path virtio_iso_target
      iso_drive_letter 'Z'
      action :dismount
    end
  end

  chocolatey_package 'rsync' do
    action :install
  end
end

reboot 'gusztavvargadr_packer_windows' do
  action :nothing
end

reboot 'gusztavvargadr_packer_windows::initialize' do
  delay_mins 1
  action :reboot_now
  only_if { reboot_pending? }
end
