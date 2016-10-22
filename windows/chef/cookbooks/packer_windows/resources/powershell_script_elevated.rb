property :command, String, name_property: true
property :user, String, default: 'vagrant'
property :password, String, default: 'vagrant'
property :cwd, String, default: 'C:\\'
property :code, String, required: true
property :wait_poll, Integer, default: 5

action :run do
  script_directory_path = "#{Chef::Config[:file_cache_path]}/packer_windows"
  directory script_directory_path do
    recursive true
    action :create
  end

  script_file_path = "#{script_directory_path}/powershell_script_elevated.ps1"
  file script_file_path do
    content code
    action :create
  end

  windows_task_name = 'powershell_script_elevated'
  windows_task_command = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -NoProfile -ExecutionPolicy Bypass -File '#{script_file_path.gsub('/', '\\')}'"
  windows_task windows_task_name do
    user new_resource.user
    password new_resource.password
    cwd new_resource.cwd
    command windows_task_command
    action [ :create, :run ]
    run_level :highest
    force true
  end

  powershell_script "Wait for task #{windows_task_name}" do
    code <<-EOH
      $taskName = "#{windows_task_name}"
      while (1)
      {
          $stat = schtasks /query /tn $taskName |
                      Select-String "$taskName.*?\\s(\\w+)\\s*$" |
                      Foreach {$_.Matches[0].Groups[1].value}
          if ($stat -ne 'Running')
          {
              break
          }
          Start-Sleep #{wait_poll}
      }
    EOH
    action :run
  end

  windows_task windows_task_name do
    action :delete
  end

  file script_file_path do
    action :delete
  end
end
