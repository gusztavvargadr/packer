include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_windows_uac '' do
  action :disable
end

gusztavvargadr_windows_remote_desktop '' do
  action :enable
end

gusztavvargadr_windows_defender '' do
  action :disable
end

powershell_script 'Disable Scheduled Defrag' do
  code 'Schtasks.exe /change /disable /tn "\Microsoft\Windows\Defrag\ScheduledDefrag"'
  action :run
end
