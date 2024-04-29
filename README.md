# metasploit-vagrant-builds

This repository hold tools for creating vagrant systems used by the Metasploit Framework to build and release artifacts.

## Building

To build locally first install `packer`.

### Local building

Windows is currently built remotely on AWS, but OSX must be built locally. It is possible to build the macOS and Windows systems locally:

* `git submodule update --init`
* Install `vmware_desktop` or `virtualbox`
* If using `virtualbox` update the `templates\metasploitMacOSBuilder.json` `vagrant_provider` to `virtualbox`
* Add a `authorized_keys` file (this is required to build, see [Security considerations](#security-considerations) section for more information)
* Manually source the macOS/Windows ISO files (Steps for OSX below)
* Execute `./buildBoxes.sh`
* To debug a failing build you can use the `-on-error=ask` packer flag to inspect a failed VM, or the `PACKER_LOG=1` environment variable to log vagrant commands and their results

In some cases importing the seed macOS source box currently from vagrantcloud into your vagrant environment may be need.
The project is currently utilizing a prebuild macinabox image referenced in `resources/macos/macos.json`

Build systems for macOS can only be created on macOS and requires a `.dmg` file:

```shell
# Find available software
softwareupdate --list-full-installers

# Download the required version
softwareupdate --fetch-full-installer --full-installer-version 11.7.10

# Create a new sparse disk image
hdiutil create -o 'Install_macOS_11.7.10' -size 16384m -volname Install_macOS_11.7.10 -layout SPUD -fs HFS+J

# Mount the dmg
hdiutil attach Install_macOS_11.7.10.dmg -noverify -mountpoint '/Volumes/Big Sur'

# Create intstall media dmg
sudo /Applications/Install\ macOS\ Big\ Sur.app/Contents/Resources/createinstallmedia --volume '/Volumes/Big Sur'

# Detatch the bootable installer
hdiutil detach -force '/Volumes/Big Sur'
```

If your target virtualization environment is running an older ESXi version (i.e. 6.7 or below) - it may be easier to create the base
vagrant VM directly in ESXi first:

```
# Pull the base box:
vagrant box add --box-version 2020.08.21 --provider vmware_desktop ekai-upt/macos-catalina

# Move into the VM directory:
cd ~/.vagrant.d/boxes/ekai-upt-VAGRANTSLASH-macos-catalina/2020.08.21/vmware_desktop

# Create a new VM on ESXi:
time /Applications/VMware\ Fusion.app/Contents/Library/VMware\ OVF\ Tool/ovftool \
    --overwrite \
    --diskMode=thin \
    --numberOfCpus:'*'=4 \
    --memorySize:'*'=8192 \
    --maxVirtualHardwareVersion=15 \
    --network=<network> \
    --datastore=<datastore> \
    --vmFolder=Metasploit \
    --compress=9 \
    --name=metasploitMacOSBuilder-<version>  \
    macinbox.vmx \
    vi://<vcenter_host>:443/<datacenter>/host/<esxi_host>/
```

Then Resize the VM on VSphere from 64gb to 84gb, boot it - and run disktuil `diskutil apfs resizeContainer disk0s2 84G`.
Then remotely provision the VM with packer's [null builder](https://developer.hashicorp.com/packer/docs/builders/null):

```json5
{
  "_command": "Build with `packer build macos.json`",
  "builders": [
    {
      "type": "null",
      "ssh_host": "x.x.x.x",
      "ssh_username": "{{ user `ssh_username` }}",
      "ssh_password": "{{ user `ssh_password` }}"
    }
  ]
  // ...
}
```

This ensures that the created VM is compatible with with the host's hypervisor. This fixes an issue of building locally with
a newer VMWare fusion version may leave a VM that isn't bootable on a remote ESXi server. macOS provisioning take ~4 hours to finish.

Then execute packer:

```
PACKER_LOG=1 packer build -on-error=abort -var-file=templates/metasploitMacOSBuilder.json resources/macos/macos.json
```

If you've remotely provisioned an existing ESXi target - you will want to convert the VM to a template afterwards.

Example of testing the locally built OSX box:

```shell
vagrant box add metasploitMacOSBuilder-1.0.8 ./box/vmware_desktop/metasploitMacOSBuilder-1.0.8.box
vagrant init metasploitMacOSBuilder-1.0.8
vagrant up --provider=vmware_desktop
vagrant ssh
```

Example of uploading a locally built Vagrant box to vSphere with vmware's `ovftool`:

```
# Extract the box; to gain access to the box.vmx metadata file:
tar xvf metasploitMacOSBuilder-1.0.8.box

# Upload to vSphere
/Applications/VMware\ Fusion.app/Contents/Library/VMware\ OVF\ Tool/ovftool \
    --overwrite \
    --diskMode=thin \
    --numberOfCpus:'*'=4 \
    --memorySize:'*'=8192 \
    --maxVirtualHardwareVersion=15 \
    --network=<network> \
    --datastore=<datastore> \
    --importAsTemplate \
    --vmFolder=Metasploit \
    --compress=9 \
    --name=metasploitMacOSBuilder-<version>  \
    box.vmx \
    vi://<vcenter_host>:443/<datacenter>/host/<esxi_host>/
```

### Building remotely

Note: macOS not yet supported with remote builds.

To build the Windows system remotely on an AWS environment:

```
# Create a temporary install password; By defafult you can WinRM into this account with vagrant:$INSTALL_PASSWORD
export INSTALL_PASS=$(openssl rand -base64 9 | tr -d '\r\n')
echo "The temporary WinRM credentials will be: vagrant:${INSTALL_PASS}"

# Install any required terraform plugins
packer init resources/windows/windows.pkr.hcl

# Validate the packer configuration
packer validate -var "install_pass=${INSTALL_PASS}" -var "authorized_keys_path=./resources/authorized_keys" resources/windows/windows.pkr.hcl

# Build on AWS
packer build -var "install_pass=${INSTALL_PASS}" -var "authorized_keys_path=./resources/authorized_keys" resources/windows/windows.pkr.hcl
```

This will create a new AMI, and replace the existing AMI if present:

```
# Replace an existing AMI. Warning - do this only if you are creating a new unused version:
packer build -var "install_pass=${INSTALL_PASS}" -var "authorized_keys_path=./resources/authorized_keys" -var "force_deregister=true" -var "force_delete_snapshot=true" resources/windows/windows.pkr.hcl
```

### Debugging

To debug a failing build you can use the `-on-error=ask` flag or the `PACKER_LOG=1` environment variable:

```
packer build -var "install_pass=${INSTALL_PASS}" -var "authorized_keys_path=./resources/authorized_keys" -on-error=ask resources/windows/windows.pkr.hcl
```

You can remote into the machine via WinRM tooling, potentially via Metasploit:

```msf
msf6 auxiliary(scanner/winrm/winrm_login) > run rhost=50.18.26.233 username=Administrator password=MJ72x)O7R3D-96VbAPX).0M%nlZv9bHP rport=5986

[!] No active DB -- Credential data will not be saved!
[+] 50.18.26.233:5986 - Login Successful: WORKSTATION\Administrator:MJ72x)O7R3D-96VbAPX).0M%nlZv9bHP
[*] Command shell session 1 opened (x.x.x.x:52424 -> x.x.x.x:5986) at 2023-11-16 12:44:46 +0000
[*] Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed

msf6 auxiliary(scanner/winrm/winrm_login) > sessions -i -1
[*] Starting interaction with 1...

Microsoft Windows [Version 10.0.17763.4974]
(c) 2018 Microsoft Corporation. All rights reserved.

C:\Users\Administrator>
```

The `-debug` flag can be used to pause at each step as well, which will extract and print the remote EC2 build password directly
not just the temporary Administrator account that is created:

```
$ packer build -var "install_pass=${INSTALL_PASS}" -var "authorized_keys_path=./resources/authorized_keys" -debug -on-error=ask resources/windows/windows.pkr.hcl
...
==> win-builder-base.amazon-ebs.metasploit-windows-builder: Waiting for instance (i-0f18b8be1c11b0893) to become ready...
win-builder-base.amazon-ebs.metasploit-windows-builder: Public DNS: ec2-50-18-26-233.us-west-1.compute.amazonaws.com
win-builder-base.amazon-ebs.metasploit-windows-builder: Public IP: 50.18.26.233
win-builder-base.amazon-ebs.metasploit-windows-builder: Private IP: 172.31.13.97
==> win-builder-base.amazon-ebs.metasploit-windows-builder: Pausing after run of step 'StepRunSourceInstance'. Press enter to continue.
==> win-builder-base.amazon-ebs.metasploit-windows-builder: Waiting for auto-generated password for instance...
win-builder-base.amazon-ebs.metasploit-windows-builder: It is normal for this process to take up to 15 minutes,
win-builder-base.amazon-ebs.metasploit-windows-builder: but it usually takes around 5. Please wait.
win-builder-base.amazon-ebs.metasploit-windows-builder:
win-builder-base.amazon-ebs.metasploit-windows-builder: Password retrieved!
win-builder-base.amazon-ebs.metasploit-windows-builder: Password (since debug is enabled): MJ72x)O7R3D-96VbAPX).0M%nlZv9bHP
==> win-builder-base.amazon-ebs.metasploit-windows-builder: Pausing after run of step 'StepGetPassword'. Press enter to continue.
```

See more details in the [documentation](https://github.com/hashicorp/packer/blob/c245b1fb7c87fdf2e655887d49f8ad75c59b7e2b/website/content/docs/debugging.mdx#L9)

### Security considerations

The created AMI will require an SSH authorized key to be able to log into the box - by default this is set to `./resources/authorized_keys`. If you are a Rapid7 Metasploit maintainer, pre-existing keys have been made available to you via an internal password manager.

Hashicorp does offer [vagrant's "insecure" keypairs](https://github.com/hashicorp/vagrant/tree/9b460ecedefa45a557b1c13c63449839819dc220/keys#insecure-keypairs), which are weak credentials and allow anyone with vagrant's "insecure" keypairs to access the machine. **This is not advised and is not secure**, if this method is chosen you should at the very least behind a restricted security group (i.e. limited to office/host IP addresses).

Example of adding the keys to the `./resources/authorized_keys` file and SSH'ing in via Vagrant's private key, **again this is not secure**:

Add the keys:
```bash
curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub  > ./resources/authorized_keys
```

Example of SSH'ing in via Vagrant's private key:
```bash
curl -L -o ./vagrant_key https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant
chmod 600 ./vagrant_key

ssh -o PubkeyAcceptedKeyTypes=ssh-rsa -v -i ./vagrant_key vagrant@ec2-54-215-236-141.us-west-1.compute.amazonaws.com
```
