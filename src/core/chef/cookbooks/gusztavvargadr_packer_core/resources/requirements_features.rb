property :requirements_features_options, Hash

default_action :enable

action :enable do
  return if requirements_features_options.nil?

  requirements_features_options.each do |feature_name, _feature_options|
    gusztavvargadr_windows_windows_feature feature_name do
      action :enable
    end
  end
end
