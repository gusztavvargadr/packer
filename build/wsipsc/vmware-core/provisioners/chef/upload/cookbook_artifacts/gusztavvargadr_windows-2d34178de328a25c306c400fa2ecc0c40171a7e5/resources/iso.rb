unified_mode true

provides :gusztavvargadr_windows_iso

property :iso_path, String, name_property: true
property :iso_drive_letter, String, required: true

default_action :mount

action :mount do
  powershell_script "Mount '#{new_resource.iso_path}' at '#{new_resource.iso_drive_letter}'" do
    code <<-EOH
      $mountResult = Mount-DiskImage #{new_resource.iso_path.tr('/', '\\')} -PassThru -NoDriveLetter
      mountvol #{new_resource.iso_drive_letter}: ($mountResult | Get-Volume).UniqueId
    EOH
    action :run
  end
end

action :dismount do
  powershell_script "Dismount '#{new_resource.iso_path}'" do
    code <<-EOH
      Dismount-DiskImage #{new_resource.iso_path}
    EOH
    action :run
  end
end
