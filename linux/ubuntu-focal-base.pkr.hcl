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
  image_name = "${var.prefix}-ubuntu22-base-${local.timestamp}"
}

source "azure-arm" "base" {
  os_type                   = "Linux"
  build_resource_group_name = var.az_resource_group
  vm_size                   = "Standard_DS1_v2"

  # Source image
  # $ az vm image list --output table
  # Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_sku       = "22_04-lts-gen2"
  image_version   = "latest"

  shared_image_gallery_destination {
    subscription         = var.az_subscription_id
    resource_group       = var.az_resource_group
    gallery_name         = var.az_image_gallery
    image_name           = "ubuntu-base"
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
  sources = [
    "source.azure-arm.base"
  ]

  # Make sure cloud-init has finished
  provisioner "shell" {
    inline = ["echo 'Wait for cloud-init...' && /usr/bin/cloud-init status --wait"]
  }

  provisioner "shell" {
    script          = "${path.root}/scripts/update.sh"
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
  }
}
