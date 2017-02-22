cp C:\Users\Public\Downloads\packer\BeforeSysprep.cmd C:\ProgramData\Amazon\EC2-Windows\Launch\Sysprep
cp C:\Users\Public\Downloads\packer\SysprepSpecialize.cmd.cmd C:\ProgramData\Amazon\EC2-Windows\Launch\Sysprep

cd C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts
.\InitializeInstance.ps1 -Schedule
.\SysprepInstance.ps1

shutdown /s /t 10