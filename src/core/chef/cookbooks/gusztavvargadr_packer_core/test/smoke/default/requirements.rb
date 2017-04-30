environment_query_script = <<-EOH
  [environment]::GetEnvironmentVariable("VARIABLE_NAME", "User")
EOH
environment_value = 'VARIABLE_VALUE'

describe powershell(environment_query_script) do
  its('stdout') { should include environment_value }
end

feature_executable_file = '/Windows/System32/telnet.exe'

describe file(feature_executable_file) do
  it { should exist }
end
