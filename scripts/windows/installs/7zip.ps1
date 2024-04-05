# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

chocolatey feature enable -n=allowGlobalConfirmation
choco install 7zip
chocolatey feature disable -n=allowGlobalConfirmation
