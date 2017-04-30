dotnet_directory = '/Program Files/dotnet'

describe directory(dotnet_directory) do
  it { should exist }
end
