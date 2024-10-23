terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
    }
  }
}

resource "virtualbox" "ceph_nodes" {
  count = 3 # Создаем 3 ноды Ceph
  name = "ceph0${count.index + 1}"

  cores = 2
  sockets = 1
  cpu = "host"
  memory = 4096
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
          size      = "15G"
          storage   = var.storage_name
        }
      }
    }
    scsi {
      scsi1 {
        disk {
          size      = "50G"
          storage   = var.storage_name
        }
      }
    }
    scsi {
      scsi2 {
        disk {
          size      = "50G"
          storage   = var.storage_name
        }
      }
    }
  }
  # Настраиваем использование в VirtualBox сетевого моста vmbr0, который подключен к mgmt сети кластера
  network_adapter {
    type = "bridge"
    host_interface = "vboxnet1"
  }
  network_adapter {
    type = "hostonly"
    host_interface = "vboxnet2"
  }


  # Опеределяем порядок загрузки
  boot = "order=scsi0"

  # Настраиваем IP адреса VM из пула адресов mgmt подсети 192.168.101.131, 192.168.101.132 и 192.168.101.133
  ipconfig0 = "ip=192.168.101.13${count.index + 1}/24,gw=192.168.101.1"
  ipconfig1 = "ip=10.10.201.13${count.index + 1}/24,gw=10.10.201.1"
  
  # Настраиваем креды пользователя и ssh ключ
  ciuser="root"
  cipassword = "qwerty123"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}