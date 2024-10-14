terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

# Настраиваем подключение к ProxMox с помощью API token
provider "proxmox" {
  pm_api_url = var.api_proxmox_address
  pm_api_token_id = var.api_token_id
  pm_api_token_secret = var.api_token_secret
  pm_tls_insecure = true
  pm_parallel = 1
}

resource "proxmox_vm_qemu" "test_server" {
  count = 2 # Создаем 2 VM
  name = "debian12-vm-${count.index + 1}" 
  target_node = var.proxmox_host
  clone = var.template_name
  full_clone = true

  agent = 1
  os_type = "cloud-init"
  cores = 1
  sockets = 1
  cpu = "host"
  memory = 1024
  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"

  # Setup disks
  disks {
    ide {
      ide2 {
        cloudinit {
          storage = var.storage_name
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size      = "5G"
          storage   = var.storage_name
        }
      }
    }
  }
  # if you want two NICs, just copy this whole network section and duplicate it
  network {
    model = "virtio"
    bridge = "vmbr0"
    firewall = false
    link_down = false 
  }
  # not sure exactly what this is for. presumably something about MAC addresses and ignore network changes during the life of the VM
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  
  # Specify the boot order
  boot = "order=ide2;scsi0"

  # New VMs should have IP addresses 192.168.101.23x (192.168.101.231 and etc.)
  ipconfig0 = "ip=192.168.101.23${count.index + 1}/24,gw=192.168.101.1"
  
  # sshkeys set using variables. the variable contains the text of the key.
  ciuser="smikheev"
  cipassword = "qwerty123"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
