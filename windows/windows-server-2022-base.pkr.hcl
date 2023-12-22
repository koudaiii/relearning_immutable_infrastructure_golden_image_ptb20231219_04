# see https://qiita.com/m-oka-system/items/fc7428a566b3d6f4b724
packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

locals {
  timestamp  = regex_replace(timestamp(), "[- TZ:]", "")
  image_name = "${var.prefix}-windows2022-base-${local.timestamp}"
}

source "azure-arm" "windowsserver-2022" {
  os_type                   = "Windows"
  build_resource_group_name = var.az_resource_group
  vm_size                   = "Standard_DS1_v2"

  # Source image
  # $ az vm image list --output table
  # MicrosoftWindowsServer:WindowsServer:2022-datacenter-g2:latest
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2022-datacenter-g2"
  image_version   = "latest"

  winrm_insecure = true
  communicator                 = "winrm"
  winrm_timeout                = "5m"
  winrm_use_ssl                = true
  winrm_username               = "packer"
  winrm_password               = var.winrm_password
  allowed_inbound_ip_addresses = var.inbound_ip_addresses

  ## Note: If saving to Compute Gallery, specify the parameters in the `shared_image_gallery_destination` block.
  ## If you want to save to both, `specify managed_image_*` parameters for both.
  shared_image_gallery_destination {
    subscription         = var.az_subscription_id
    resource_group       = var.az_resource_group
    gallery_name         = var.az_image_gallery
    image_name           = "windows2022-base"
    image_version        = formatdate("YYYY.MMDD.hhmm", timestamp())
    replication_regions  = [var.az_region]
    storage_account_type = "Standard_LRS"
  }

  spot {
    max_price       = "-1"
    eviction_policy = "Deallocate"
  }

  azure_tags = {
    owner      = var.owner
    department = var.department
    build-time = local.timestamp
  }
  use_azure_cli_auth = true
}

build {
  sources = ["source.azure-arm.windowsserver-2022"]

  # Transfer the registry files.
  provisioner "file" {
    source      = "${path.root}/registry/"
    destination = "C:/"
  }

  # Download and install language packs.
  provisioner "powershell" {
    scripts = [
      "${path.root}/scripts/install_language_pack.ps1",
    ]
  }

  provisioner "windows-restart" {}

  # Language Settings.
  provisioner "powershell" {
    scripts = [
      "${path.root}/scripts/set_ja_jp_langauage.ps1",
    ]
  }

  provisioner "windows-restart" {}

  # Running Sysprep.
  provisioner "powershell" {
    inline = [
      "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /generalize /oobe /mode:vm /quiet /quit",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }
}
