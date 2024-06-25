# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

chocolatey feature enable -n=allowGlobalConfirmation
choco install cmake --installargs '"ADD_CMAKE_TO_PATH=System"'
chocolatey feature disable -n=allowGlobalConfirmation
