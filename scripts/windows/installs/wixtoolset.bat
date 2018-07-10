chocolatey feature enable -n=allowGlobalConfirmation
choco install wixtoolset
chocolatey feature disable -n=allowGlobalConfirmation
setx PATH "%PATH%;C:\Program Files (x86)\WiX Toolset v3.11\bin"
