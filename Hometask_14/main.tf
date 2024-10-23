terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
    }
  }
}

resource "virtualbox_vm" "ceph_nodes" {
  count = 3 # Создаем 3 ноды Ceph
  name = "ceph0${count.index + 1}"
  image = "/User/smikheev/Downloads/28ded8c9-002f-46ec-b9f3-1d7d74d147ee" # Debian 12 image from Vagrant Boxes

  cpus = 2
  memory = "4096 MiB"
  bootdisk = "scsi0"

  # Setup disks
  disks {
    scsi {
      scsi0 {
        disk {
          size      = "15G"
        }
      }
    }
    scsi {
      scsi1 {
        disk {
          size      = "50G"
        }
      }
    }
    scsi {
      scsi2 {
        disk {
          size      = "50G"
        }
      }
    }
  }
  # Настраиваем использование в VirtualBox сетевого моста vmbr0, который подключен к mgmt сети кластера
  network_adapter {
    type = "bridge"
    host_interface = "vboxnet1"
  }
  network_adapter_2 {
    type = "hostonly"
    host_interface = "vboxnet2"
  }


  # Опеределяем порядок загрузки
  boot = "order=scsi0"

  # Настраиваем IP адреса VM
  output "IPAddr" {
  value = element(virtualbox_vm.ceph_nodes.*.network_adapter.0.ipv4_address, 1)
  }

  output "IPAddr_2" {
  value = element(virtualbox_vm.ceph_nodes.*.network_adapter_2.0.ipv4_address, 2)
  }
  
  # Настраиваем креды пользователя и ssh ключ
  ciuser="root"
  cipassword = "qwerty123"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
