(New-Object System.Net.WebClient).DownloadFile('https://archive.org/download/msdn_2023/en_visual_studio_express_2013_for_windows_desktop_with_update_4_x86_dvd_5920567.iso', 'C:\Windows\Temp\vs2013express.iso')

$VerifyHash = '92bf845a8520fd20639867f60def51a678d75f4e8adc7ef8e9750d04e30525bc'
$FileHash = (Get-FileHash C:\Windows\Temp\vs2013express.iso -Algorithm SHA256).Hash

if ($VerifyHash -ne $FileHash) {
 exit -1
}

cmd /c '7z x "C:\Windows\Temp\vs2013express.iso" -oC:\Windows\Temp\VS2013'

cmd /c "C:\Windows\Temp\VS2013\wdexpress_full.exe /Passive /NoRestart /Log VisualStudioExpress2013Windows.log"

rm -rf C:\Windows\Temp\VS2013
