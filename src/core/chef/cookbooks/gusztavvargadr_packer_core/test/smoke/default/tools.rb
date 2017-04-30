chocolatey_executable_file = '/ProgramData/chocolatey/bin/NuGet.exe'

describe file(chocolatey_executable_file) do
  it { should exist }
end

windows_executable_file = '/Program Files/dotnet/dotnet.exe'

describe file(windows_executable_file) do
  it { should exist }
end

files_file = '/Users/vagrant/hosts'

describe file(files_file) do
  it { should exist }
end
