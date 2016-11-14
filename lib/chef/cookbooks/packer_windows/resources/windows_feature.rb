property :feature_name, String, name_property: true

action :enable do
  packer_windows_powershell_script_elevated "Enable Windows Feature #{feature_name}" do
    code <<-EOH
      dism /online /enable-feature /featurename:#{feature_name} /all
    EOH
  end
end
