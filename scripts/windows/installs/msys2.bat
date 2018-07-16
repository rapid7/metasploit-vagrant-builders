chocolatey feature enable -n=allowGlobalConfirmation
choco install msys2
chocolatey feature disable -n=allowGlobalConfirmation
shutdown -r -t 00
