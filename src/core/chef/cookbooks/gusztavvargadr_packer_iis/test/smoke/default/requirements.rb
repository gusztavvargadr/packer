dotnet35_directory = '/Windows/Microsoft.NET/Framework/v3.5'

describe directory(dotnet35_directory) do
  it { should exist }
end

dotnet40_directory = '/Windows/Microsoft.NET/Framework/v4.0.30319'

describe directory(dotnet40_directory) do
  it { should exist }
end

iis_directory = '/inetpub/wwwroot'

describe directory(iis_directory) do
  it { should exist }
end
