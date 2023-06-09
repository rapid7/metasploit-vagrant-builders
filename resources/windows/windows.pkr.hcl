variable "aws_access_key" {
  type    = string
  default = "${env("AWS_ACCESS_KEY_ID")}"
}

variable "aws_secret_key" {
  type    = string
  default = "${env("AWS_SECRET_ACCESS_KEY")}"
}

variable "region" {
  type    = string
  default = "us-west-1"
}

variable "install_user" {
  type    = string
  default = "vagrant"
}

variable "install_pass" {
  type    = string
  default = "P@ssw0rd"
}

source "amazon-ebs" "win-source" {
  force_deregister      = true
  force_delete_snapshot = true
  access_key     = var.aws_access_key
  communicator   = "winrm"
  instance_type  = local.instance_type
  region         = var.region
  secret_key     = var.aws_secret_key
  user_data_file = "./resources/windows/userdata.ps1"
  winrm_username = local.win_factory.user
  winrm_insecure = true
  winrm_use_ssl  = true
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 60
    volume_type           = "gp2"
  }
}

locals {
  instance_type = "t2.medium"
  version       = "1.0.6"
  win_factory = {
    owner = "amazon"
    user  = "Administrator"
    images = [
      {
        filter = "*Windows_Server-2019-English-Core-Base*"
        name   = "metasploit-windows-builder"
      }
    ]
  }
}

build {
  name        = "win-builder-base"
  description = "Generates Metasploit build Windows AMIs"

  dynamic "source" {
    for_each = local.win_factory.images
    labels   = ["amazon-ebs.win-source"]
    content {
      ami_name = source.value.name
      name     = source.value.name
      source_ami_filter {
        filters = {
          name                = source.value.filter
          root-device-type    = "ebs"
          virtualization-type = "hvm"
        }
        owners      = [local.win_factory.owner]
        most_recent = true
      }
      tags = {
        Name    = source.value.name
        Version = local.version
      }
    }
  }

  provisioner "file" {
    destination  = "C:/vagrant"
    pause_before = "1m0s"
    source       = "scripts"
  }

  provisioner "file" {
    destination = "C:/vagrant"
    source      = "resources"
  }


  provisioner "powershell" {
    inline = ["net user ${var.install_user} ${var.install_pass} /ADD",
              "net localgroup 'Administrators' ${var.install_user} /ADD"]
  }

  provisioner "powershell" {
    elevated_user     = var.install_user
    elevated_password = var.install_pass
    scripts           = ["./scripts/windows/configs/update_root_certs.bat",
                         "./scripts/windows/configs/disable-auto-logon.bat",
                         "./scripts/windows/configs/disable-firewall.bat",
                         "./scripts/windows/configs/enable-rdp.bat",
                         "./scripts/windows/installs/openssh.ps1"]
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    elevated_user     = var.install_user
    elevated_password = var.install_pass
    scripts            = ["scripts/windows/configs/ssh-auth.ps1"]
  }

  provisioner "powershell" {
    elevated_user     = var.install_user
    elevated_password = var.install_pass
    inline            = ["$env:chocolateyVersion = '1.4.0'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))"]
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    elevated_user     = var.install_user
    elevated_password = var.install_pass
    scripts           = ["scripts/windows/installs/install_boxstarter.bat",
                         "scripts/windows/installs/7zip.bat",
                         "scripts/windows/installs/vcredist2008.bat"]
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    elevated_user     = var.install_user
    elevated_password = var.install_pass
    scripts           = ["scripts/windows/installs/git.bat",
                         "scripts/windows/installs/mingw-64.bat",
                         "scripts/windows/installs/msys2.bat"]
  }

  provisioner "powershell" {
    inline = ["Uninstall-WindowsFeature -Name Windows-Defender"]
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    inline = ["Install-WindowsFeature NET-Framework-Core"]
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    elevated_user   = var.install_user
    elevated_password = var.install_pass
    scripts         = ["scripts/windows/installs/java.bat",
                       "scripts/windows/installs/install_ruby.bat",
                       "scripts/windows/installs/ruby_devkit.bat",
                       "scripts/windows/installs/wixtoolset.bat"]
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    elevated_user     = var.install_user
    elevated_password = var.install_pass
    scripts           = ["scripts/windows/installs/vs2013.ps1"]
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    elevated_user     = var.install_user
    elevated_password = var.install_pass
    scripts           = ["scripts/windows/installs/python2.bat",
                         "scripts/windows/installs/python3.bat"]
  }

  provisioner "windows-restart" {
  }

  provisioner "windows-shell" {
    scripts = ["scripts/windows/configs/set_path.bat",
               "scripts/windows/configs/prep_omnibus.bat",
               "scripts/windows/configs/packer_cleanup.bat"]
  }
}
