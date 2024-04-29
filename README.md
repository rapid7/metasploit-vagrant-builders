# metasploit-vagrant-builds

This repository hold tools for creating vagrant systems used by the Metasploit Framework to build and release artifacts.

## Building

To build locally first install `packer`.

### Local building

To build the macOS and Windows systems locally:

* Install `vmware_desktop` or `virtualbox`
* If using `virtualbox` update the `templates\metasploitMacOSBuilder.json` `vagrant_provider` to `virtualbox`
* Add a `authorized_keys` file (this is required to build, see [Security considerations](#security-considerations) section for more information)
* Manually source the macOS/Windows ISO files
* Execute `./buildBoxes.sh`

Build systems for macOS can only be created on macOS.

In some cases importing the seed macOS source box currently from vagrantcloud into your vagrant environment may be need.

The project is currently utilizing a prebuild macinabox image referenced in `resources/macos/macos.json`

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

To debug a failing build you can use the `-on-error=ask` flag:

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
