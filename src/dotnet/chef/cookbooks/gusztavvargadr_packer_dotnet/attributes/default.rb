default['gusztavvargadr_packer_dotnet']['default'] = {
  'features' => {
    'NetFx3' => {},
  },
  'native_packages' => {
    '.NET Core 1.1.4 Runtime' => {
      'source' => 'https://download.microsoft.com/download/6/F/B/6FB4F9D2-699B-4A40-A674-B7FF41E0E4D2/dotnet-win-x64.1.1.4.exe',
      'install' => [
        '/install',
        '/quiet',
        '/norestart',
      ],
    },
    '.NET Core 2.0.0 Runtime' => {
      'source' => 'https://download.microsoft.com/download/5/6/B/56BFEF92-9045-4414-970C-AB31E0FC07EC/dotnet-runtime-2.0.0-win-x64.exe',
      'install' => [
        '/install',
        '/quiet',
        '/norestart',
      ],
    },
  },
}
