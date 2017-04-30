property :requirements_options, Hash

default_action :ensure

action :ensure do
  return if requirements_options.nil?

  gusztavvargadr_packer_core_requirements_environment '' do
    requirements_environment_options requirements_options['environment']
    action :update
  end

  gusztavvargadr_packer_core_requirements_features '' do
    requirements_features_options requirements_options['features']
    action :enable
  end
end
