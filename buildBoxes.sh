#!/bin/bash
packer build -var-file=templates/metasploitMacOSBuilder.json resources/macos/macos.json
packer build -var-file=templates/metasploitWindowsBuilder.json resources/windows/windows.json
