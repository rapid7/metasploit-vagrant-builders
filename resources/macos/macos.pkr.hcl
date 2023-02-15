variable "autologin" {
  type    = string
  default = "true"
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "disk_size" {
  type    = string
  default = "65536"
}

variable "install_vagrant_keys" {
  type    = string
  default = "true"
}

variable "install_xcode_cli_tools" {
  type    = string
  default = "true"
}

variable "iso_url" {
  type    = string
  default = "dmg/OSX_InstallESD_10.11_15A284.dmg"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "parallels_guest_os_type" {
  type    = string
  default = "win-8"
}

variable "ssh_password" {
  type    = string
  default = "vagrant"
}

variable "ssh_username" {
  type    = string
  default = "vagrant"
}

variable "update" {
  type    = string
  default = "true"
}

variable "vagrantfile_template" {
  type    = string
  default = ""
}

variable "version" {
  type    = string
  default = "0.1.0"
}

variable "virtualbox_guest_os_type" {
  type    = string
  default = "MacOS1011_64"
}

variable "vm_name" {
  type    = string
  default = "macos1011"
}

variable "vmware_guest_os_type" {
  type    = string
  default = "darwin15-64"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "parallels-iso" "macOSBuilder" {
  boot_wait              = "5s"
  disk_size              = "${var.disk_size}"
  guest_os_type          = "${var.parallels_guest_os_type}"
  iso_checksum_type      = "none"
  iso_url                = "${var.iso_url}"
  output_directory       = "output-${var.vm_name}-parallels-iso"
  parallels_tools_flavor = "mac"
  prlctl                 = [["set", "{{ .Name }}", "--memsize", "${var.memory}"], ["set", "{{ .Name }}", "--memquota", "512:${var.memory}"], ["set", "{{ .Name }}", "--cpus", "${var.cpus}"], ["set", "{{ .Name }}", "--distribution", "macosx"], ["set", "{{ .Name }}", "--3d-accelerate", "highest"], ["set", "{{ .Name }}", "--high-resolution", "off"], ["set", "{{ .Name }}", "--auto-share-camera", "off"], ["set", "{{ .Name }}", "--auto-share-bluetooth", "off"], ["set", "{{ .Name }}", "--on-window-close", "keep-running"], ["set", "{{ .Name }}", "--isolate-vm", "off"], ["set", "{{ .Name }}", "--shf-host", "off"]]
  shutdown_command       = "echo '${var.ssh_username}'|sudo -S shutdown -h now"
  ssh_password           = "${var.ssh_password}"
  ssh_port               = 22
  ssh_username           = "${var.ssh_username}"
  ssh_wait_timeout       = "10000s"
  vm_name                = "${var.vm_name}"
}

source "virtualbox-iso" "macOSBuilder" {
  boot_wait            = "2s"
  disk_size            = "${var.disk_size}"
  guest_additions_mode = "disable"
  guest_os_type        = "${var.virtualbox_guest_os_type}"
  hard_drive_interface = "sata"
  iso_checksum_type    = "none"
  iso_interface        = "sata"
  iso_url              = "${var.iso_url}"
  output_directory     = "output-${var.vm_name}-virtualbox-iso"
  post_shutdown_delay  = "1m"
  shutdown_command     = "echo '${var.ssh_username}'|sudo -S shutdown -h now"
  ssh_password         = "${var.ssh_password}"
  ssh_port             = 22
  ssh_username         = "${var.ssh_username}"
  ssh_wait_timeout     = "10000s"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--audiocontroller", "hda"], ["modifyvm", "{{ .Name }}", "--boot1", "dvd"], ["modifyvm", "{{ .Name }}", "--boot2", "disk"], ["modifyvm", "{{ .Name }}", "--chipset", "ich9"], ["modifyvm", "{{ .Name }}", "--firmware", "efi"], ["modifyvm", "{{ .Name }}", "--hpet", "on"], ["modifyvm", "{{ .Name }}", "--keyboard", "usb"], ["modifyvm", "{{ .Name }}", "--memory", "${var.memory}"], ["modifyvm", "{{ .Name }}", "--mouse", "usbtablet"], ["modifyvm", "{{ .Name }}", "--vram", "128"]]
  vm_name              = "${var.vm_name}"
}

source "vmware-iso" "macOSBuilder" {
  boot_wait           = "2s"
  disk_size           = "${var.disk_size}"
  guest_os_type       = "${var.vmware_guest_os_type}"
  iso_checksum_type   = "none"
  iso_url             = "${var.iso_url}"
  output_directory    = "output-${var.vm_name}-vmware-iso"
  shutdown_command    = "echo '${var.ssh_username}'|sudo -S shutdown -h now"
  skip_compaction     = true
  ssh_password        = "${var.ssh_password}"
  ssh_port            = 22
  ssh_timeout         = "10000s"
  ssh_username        = "${var.ssh_username}"
  ssh_wait_timeout    = "10000s"
  tools_upload_flavor = "darwin"
  vm_name             = "${var.vm_name}"
  vmx_data = {
    "cpuid.coresPerSocket"  = "1"
    "ehci.present"          = "TRUE"
    firmware                = "efi"
    "hpet0.present"         = "TRUE"
    "ich7m.present"         = "TRUE"
    keyboardAndMouseProfile = "macProfile"
    memsize                 = "${var.memory}"
    numvcpus                = "${var.cpus}"
    "smc.present"           = "TRUE"
    "usb.present"           = "TRUE"
  }
}

source "vagrant" "macOSBuilder" {
  communicator = "ssh"
  source_path = "ekai-upt/macos-catalina"
  box_version = "2020.10.14"
  provider = "vmware_desktop"
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.vagrant.macOSBuilder"]

  provisioner "file" {
    destination = "/private/tmp/set_kcpassword.py"
    source      = "../../boxcutter/macos/script/support/set_kcpassword.py"
  }

  provisioner "shell" {
    environment_vars  = [
                          "AUTOLOGIN=${var.autologin}",
                          "UPDATE=${var.update}",
                          "INSTALL_XCODE_CLI_TOOLS=${var.install_xcode_cli_tools}",
                          "INSTALL_VAGRANT_KEYS=${var.install_vagrant_keys}",
                          "SSH_USERNAME=${var.ssh_username}",
                          "SSH_PASSWORD=${var.ssh_password}"
                        ]
    execute_command   = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    expect_disconnect = true
    scripts           = [
                          "../../boxcutter/macos/script/vagrant.sh",
                          "../../boxcutter/macos/script/vmware.sh",
                          "../../boxcutter/macos/script/parallels.sh",
                          "../../boxcutter/macos/script/add-network-interface-detection.sh",
                          "../../boxcutter/macos/script/energy.sh",
                          "../../boxcutter/macos/script/autologin.sh"
                        ]
  }

  provisioner "shell" {
    environment_vars  = [
                          "AUTOLOGIN=${var.autologin}",
                          "UPDATE=${var.update}",
                          "INSTALL_XCODE_CLI_TOOLS=${var.install_xcode_cli_tools}",
                          "INSTALL_VAGRANT_KEYS=${var.install_vagrant_keys}",
                          "SSH_USERNAME=${var.ssh_username}",
                          "SSH_PASSWORD=${var.ssh_password}"
                        ]
    execute_command   = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    expect_disconnect = true
    scripts           = [
                          "../../boxcutter/macos/script/update.sh",
                          "../../boxcutter/macos/script/xcode-cli-tools.sh",
                        ]
    start_retry_timeout = "45m"
  }

  provisioner "shell" {
    environment_vars  = [
                          "AUTOLOGIN=${var.autologin}",
                          "UPDATE=${var.update}",
                          "INSTALL_XCODE_CLI_TOOLS=${var.install_xcode_cli_tools}",
                          "INSTALL_VAGRANT_KEYS=${var.install_vagrant_keys}",
                          "SSH_USERNAME=${var.ssh_username}",
                          "SSH_PASSWORD=${var.ssh_password}"
                        ]
    execute_command   = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    expect_disconnect = true
    scripts           = [
                          "../../scripts/macos/install_brew_req.sh",
                          "../../scripts/macos/install_rvm_req.sh"
                        ]
    start_retry_timeout = "45m"
  }

  provisioner "shell" {
    environment_vars    = [
                            "AUTOLOGIN=${var.autologin}",
                            "UPDATE=${var.update}",
                            "INSTALL_XCODE_CLI_TOOLS=${var.install_xcode_cli_tools}",
                            "INSTALL_VAGRANT_KEYS=${var.install_vagrant_keys}",
                            "SSH_USERNAME=${var.ssh_username}",
                            "SSH_PASSWORD=${var.ssh_password}"
                          ]
    execute_command     = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    expect_disconnect   = true
    scripts             = ["../../boxcutter/macos/script/minimize.sh"]
    start_retry_timeout = "10000s"
  }

#  post-processor "vagrant" {
#    keep_input_artifact  = false
#    output               = "box/${source.type}/${var.vm_name}-${var.version}.box"
#    vagrantfile_template = "${var.vagrantfile_template}"
#  }
}
