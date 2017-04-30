default['gusztavvargadr_packer_iis'] = {
  'requirements' => {
    'features' => {
      'NetFx3' => {},
      'NetFx4-AdvSrvs' => {},
      'IIS-WebServer' => {},
      'IIS-ASPNET' => {},
      'IIS-ASPNET45' => {},
    },
  },
  'tools' => {
    'windows' => {
      '.NET Core Windows Server Hosting' => {
        'source' => 'https://download.microsoft.com/download/7/E/4/7E407C90-0154-42BA-8B9E-766C9CB94C3C/DotNetCore.1.0.3_1.1.0-WindowsHosting.exe',
        'install' => '/install /quiet /norestart',
        'directory' => "#{ENV['ProgramFiles']}/dotnet",
      },
    },
  },
  'updates' => {},
  'cleanup' => {},
}
