# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

chocolatey feature enable -n=allowGlobalConfirmation
choco install python --version 3.4.4.20180111
chocolatey feature disable -n=allowGlobalConfirmation
