property :iso_path, String, name_property: true
property :drive_letter, String

action :mount do
  powershell_script "Mount #{iso_path}" do
    code <<-EOH
      $mountResult = Mount-DiskImage #{iso_path} -PassThru
      $driveLetter = ($mountResult | Get-Volume).DriveLetter
      $volume = $(mountvol $($driveletter + ":") /l).Trim()
      mountvol $($driveletter + ":") /d
      mountvol "#{drive_letter}:" $volume
    EOH
    action :run
  end
end

action :dismount do
  powershell_script "Dismount #{iso_path}" do
    code <<-EOH
      Dismount-DiskImage #{iso_path}
    EOH
    action :run
  end
end
