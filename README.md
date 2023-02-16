This repository hold tools for creating vagrant systems used by the Metasploit Framework to build and release artifacts.

To build these systems:
* install `vmware_desktop` or `virtualbox`
* install `packer` and `vagrant`
* if using `virtualbox` update templates\metasploitMacOSBuilder.json `vagrant_provider` to `virtualbox`
* execute `./buildBoxes.sh`

Build systems for macOS can only be created on macOS.
In some cases importing the seed macOS source box currently from vagrantcloud into you vagrant enviornent may be need.

The project is currently utilizing a prebuild macinabox image referenced in `resources/macos/macos.json`
