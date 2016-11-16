action :enable do
  powershell_script 'Enable Windows Defender' do
    code <<-EOH
      reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 0 /f
      reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows Defender" /v DisableRoutinelyTakingAction /t REG_DWORD /d 0 /f
    EOH
    action :run
  end
end

action :disable do
  powershell_script 'Disable Windows Defender' do
    code <<-EOH
      reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
      reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows Defender" /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f
    EOH
    action :run
  end
end
