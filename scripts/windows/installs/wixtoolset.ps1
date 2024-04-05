# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

chocolatey feature enable -n=allowGlobalConfirmation
choco install wixtoolset
chocolatey feature disable -n=allowGlobalConfirmation
