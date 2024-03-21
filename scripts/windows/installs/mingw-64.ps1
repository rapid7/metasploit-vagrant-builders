# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

chocolatey feature enable -n=allowGlobalConfirmation
choco install mingw
chocolatey feature disable -n=allowGlobalConfirmation
