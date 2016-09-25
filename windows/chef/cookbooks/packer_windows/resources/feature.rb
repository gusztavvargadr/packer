property :name, String, name_property: true
property :include_subfeatures, Object, default: false

action :install do
  powershell_script_code = "Install-WindowsFeature #{name}"
  if include_subfeatures == true
    powershell_script_code += ' -IncludeAllSubFeature'
  end

  powershell_script "Install Windows Feature #{name}" do
    code powershell_script_code
    action :run
  end
end
