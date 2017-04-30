property :environment_variable_name, String, name_property: true
property :environment_variable_value, String

default_action :update

action :update do
  powershell_script "Update environment variable #{environment_variable_name}" do
    code <<-EOH
      [Environment]::SetEnvironmentVariable("#{environment_variable_name}", "#{environment_variable_value}", "User")
    EOH
    action :run
  end
end
