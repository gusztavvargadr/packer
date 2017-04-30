property :requirements_options, Hash

default_action :ensure

action :ensure do
  return if requirements_options.nil?

  gusztavvargadr_packer_core_requirements '' do
    requirements_options new_resource.requirements_options
    action :ensure
  end

  gusztavvargadr_windows_windows_updates '' do
    action :configure
  end

  gusztavvargadr_windows_uac '' do
    action :disable
  end

  gusztavvargadr_windows_remote_desktop '' do
    action :enable
  end
end
