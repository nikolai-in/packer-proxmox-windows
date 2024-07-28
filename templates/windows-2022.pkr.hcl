packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_url" {
  type        = string
  description = "The URL of the Proxmox server"
}

variable "proxmox_username" {
  type        = string
  description = "The username to authenticate with the Proxmox server"
}

variable "proxmox_password" {
  type        = string
  description = "The password to authenticate with the Proxmox server"
  sensitive   = true
}

variable "proxmox_skip_tls_verify" {
  type        = bool
  default     = false
  description = "Skip TLS verification when connecting to the Proxmox server"
}

variable "proxmox_node" {
  type        = string
  default     = "pve"
  description = "The Proxmox node to use"
}

variable "proxmox_pool" {
  type        = string
  default     = "local"
  description = "The Proxmox pool to use"
}

variable "proxmox_vm_storage" {
  type        = string
  default     = "local-lvm"
  description = "The Proxmox storage to use for the VM"
}

variable "proxmox_iso_storage" {
  type        = string
  default     = "local"
  description = "The Proxmox storage to use for the ISO"
}

variable "winrm_username" {
  type        = string
  default     = "runner"
  description = "The username to authenticate with the WinRM service"
}

variable "winrm_password" {
  type        = string
  default     = "runner"
  description = "The password to authenticate with the WinRM service"
  sensitive   = true
}

variable "vm_name" {
  type        = string
  default     = "runner-2022"
  description = "The name of the VM"
}

variable "template_description" {
  type        = string
  default     = "Windows Server 2022 {{timestamp}}"
  description = "The description of the template"
}

variable "iso_file" {
  type        = string
  default     = "local:iso/WINDOWS_SERVER_2022_SERVER_EVAL_x64FRE_en-us.iso"
  description = "The path to the ISO file"
}

variable "iso_checksum" {
  type        = string
  default     = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
  description = "The checksum of the ISO file"
}

variable "autounattend_iso" {
  type        = string
  default     = "../assets/iso/autounattend-win22.iso"
  description = "The path to the autounattend ISO file"
}

variable "autounattend_checksum" {
  type        = string
  default     = null
  description = "The checksum of the autounattend ISO file"
}

variable "vm_cpu_cores" {
  type        = number
  default     = 2
  description = "The number of CPU cores to allocate to the VM"
}

variable "vm_memory" {
  type        = number
  default     = "8192"
  description = "The amount of memory to allocate to the VM"
}

variable "vm_disk_size" {
  type        = string
  default     = "256G"
  description = "The size of the disk to allocate to the VM"
}

variable "vm_disk_format" {
  type        = string
  default     = "raw"
  description = "The format of the disk to allocate to the VM"
}

variable "vm_sockets" {
  type        = number
  default     = 1
  description = "The number of sockets to allocate to the VM"
}

variable "os" {
  type        = string
  default     = "win10"
  description = "The operating system of the VM for the Proxmox template"
}

variable "winrm_timeout" {
  type    = string
  default = "40m"
}

source "proxmox-iso" "windows" {
  additional_iso_files {
    device           = "sata3"
    iso_checksum     = "${var.autounattend_checksum}"
    iso_storage_pool = "local"
    iso_url          = "${var.autounattend_iso}"
    unmount          = true
  }
  additional_iso_files {
    device   = "sata4"
    iso_file = "local:iso/virtio-win.iso"
    unmount  = true
  }
  additional_iso_files {
    device   = "sata5"
    iso_file = "local:iso/scripts_win22.iso"
    unmount  = true
  }
  cloud_init              = true
  cloud_init_storage_pool = "${var.proxmox_iso_storage}"
  communicator            = "winrm"
  cores                   = "${var.vm_cpu_cores}"
  disks {
    disk_size    = "${var.vm_disk_size}"
    format       = "${var.vm_disk_format}"
    storage_pool = "${var.proxmox_vm_storage}"
    type         = "sata"
  }
  insecure_skip_tls_verify = "${var.proxmox_skip_tls_verify}"
  iso_file                 = "${var.iso_file}"
  memory                   = "${var.vm_memory}"
  network_adapters {
    bridge = "vnet0"
    model  = "virtio"
  }
  node                 = "${var.proxmox_node}"
  os                   = "${var.os}"
  password             = "${var.proxmox_password}"
  pool                 = "${var.proxmox_pool}"
  proxmox_url          = "${var.proxmox_url}"
  sockets              = "${var.vm_sockets}"
  template_description = "${var.template_description}"
  template_name        = "${var.vm_name}"
  username             = "${var.proxmox_username}"
  vm_name              = "${var.vm_name}"
  winrm_insecure       = true
  winrm_no_proxy       = true
  winrm_password       = "${var.winrm_password}"
  winrm_timeout        = "${var.winrm_timeout}"
  winrm_use_ssl        = true
  winrm_username       = "${var.winrm_username}"
  task_timeout         = "6h"
}

build {
  sources = ["source.proxmox-iso.windows"]

  provisioner "powershell" {
    elevated_password = "runner"
    elevated_user     = "runner"
    scripts           = ["${path.root}/../scripts/sysprep/cloudbase-init.ps1"]
  }

  provisioner "powershell" {
    elevated_password = "runner"
    elevated_user     = "runner"
    pause_before      = "1m0s"
    scripts           = ["${path.root}/../scripts/sysprep/cloudbase-init-p2.ps1"]
  }

}