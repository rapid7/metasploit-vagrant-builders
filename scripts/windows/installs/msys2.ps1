# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

chocolatey feature enable -n=allowGlobalConfirmation
choco install msys2
chocolatey feature disable -n=allowGlobalConfirmation
