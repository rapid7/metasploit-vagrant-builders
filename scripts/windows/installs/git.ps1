# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

chocolatey feature enable -n=allowGlobalConfirmation
choco install git
chocolatey feature disable -n=allowGlobalConfirmation
