# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

chocolatey feature enable -n=allowGlobalConfirmation
choco install BoxStarter
chocolatey feature disable -n=allowGlobalConfirmation
