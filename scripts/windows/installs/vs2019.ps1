# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

$Logfile = "C:\Windows\Temp\vs2019-updates.log"

function LogWrite {
   Param ([string]$logstring)
   $now = Get-Date -format s
   Add-Content $Logfile -value "$now $logstring"
   Write-Host $logstring
}

LogWrite "Installing visual studio 2019 via chocolatey"

chocolatey feature enable -n=allowGlobalConfirmation
choco install -package visualstudio2019community --package-parameters "--config C:\vagrant\resources\windows\vs2019.vsconfig"
chocolatey feature disable -n=allowGlobalConfirmation
