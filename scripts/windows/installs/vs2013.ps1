# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

$Logfile = "C:\Windows\Temp\vs2013-updates.log"

function LogWrite {
   Param ([string]$logstring)
   $now = Get-Date -format s
   Add-Content $Logfile -value "$now $logstring"
   Write-Host $logstring
}

LogWrite "Downloading visual studio (Can take 30 minutes or more)"
[Net.ServicePointManager]::SecurityProtocol += [Net.SecurityProtocolType]::Tls12
(New-Object System.Net.WebClient).DownloadFile('https://archive.org/download/msdn_2023/en_visual_studio_express_2013_for_windows_desktop_with_update_4_x86_dvd_5920567.iso', 'C:\Windows\Temp\vs2013express.iso')
LogWrite "Finished downloading visual studio"

$VerifyHash = '92bf845a8520fd20639867f60def51a678d75f4e8adc7ef8e9750d04e30525bc'
$FileHash = (Get-FileHash C:\Windows\Temp\vs2013express.iso -Algorithm SHA256).Hash

if ($VerifyHash -ne $FileHash) {
 exit -1
}

LogWrite "Extracting visual studio"
cmd /c '7z x "C:\Windows\Temp\vs2013express.iso" -oC:\Windows\Temp\VS2013'

LogWrite "Installing visual studio"
cmd /c "C:\Windows\Temp\VS2013\wdexpress_full.exe /Passive /NoRestart /Log VisualStudioExpress2013Windows.log"

LogWrite "Removing visual studio temp files"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "C:\Windows\Temp\VS2013"
