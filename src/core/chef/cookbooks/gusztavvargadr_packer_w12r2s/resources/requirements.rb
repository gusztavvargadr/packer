property :requirements_options, Hash

default_action :ensure

action :ensure do
  return if requirements_options.nil?

  gusztavvargadr_packer_core_requirements '' do
    requirements_options new_resource.requirements_options
    action :ensure
  end

  powershell_script 'Disable Scheduled Defrag' do
    code 'Schtasks.exe /change /disable /tn "\Microsoft\Windows\Defrag\ScheduledDefrag"'
    action :run
  end
end
