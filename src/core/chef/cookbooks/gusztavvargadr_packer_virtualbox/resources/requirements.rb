property :requirements_options, Hash

default_action :ensure

action :ensure do
  return if requirements_options.nil?

  gusztavvargadr_packer_core_requirements '' do
    requirements_options new_resource.requirements_options
    action :ensure
  end

  gusztavvargadr_packer_virtualbox_guest_additions requirements_options['guest_additions_version'] do
    action :install
  end
end
