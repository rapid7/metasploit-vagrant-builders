# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

chocolatey feature enable -n=allowGlobalConfirmation
choco install vcredist2008
chocolatey feature disable -n=allowGlobalConfirmation
