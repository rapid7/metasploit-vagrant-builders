# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

chocolatey feature enable -n=allowGlobalConfirmation
choco install jre8 --version 8.0.151
chocolatey feature disable -n=allowGlobalConfirmation
