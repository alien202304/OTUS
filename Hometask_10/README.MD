# Deploy VMs in ProxMox with Terraform

1. ## Подготовка образа Debian 12 для использования в ProxMox

### Скачивается образ Debian 12 тут:
```wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2```

### Создаем вирт машину id = 9000 с 1 ядром и 1ГБ ОЗУ командой:
```qm create 9000 --memory 1024 --cores 1 --name template-debian-12-initcloud2 --net0 virtio,bridge=vmbr0```

### Импортиуем диск вирт машины в хранилище ceph_pool_1 и меняем размер диска машина на 5ГБ:
```qm importdisk 9000 debian-12-generic-amd64.qcow2 ceph_pool_1```

```qm disk resize 9000 scsi0 5G```

### Настраиваем контроллер хранилища:
```qm set 9000 --scsihw virtio-scsi-pci --scsi0 ceph_pool_1:vm-9000-disk-0```

### Создаем cloud-init для этого шаблона:
```qm set 9000 --ide2 ceph_pool_1:cloudinit```

### Задаем загрузочный диск:
```qm set 9000 --boot c --bootdisk scsi0```

### Разрешаем qemu guest агента на машине:
```qm set 9000 --agent enabled=1```

### Преобразуем машину в шаблон:
```qm template 9000```

2. ## Подключение к ProxMox кластеру

### Создаем в ProxMox пользователя deploy_tf

### Добавляем пользователю deploy_tf необходимые разрешения (permissions) для создания машин и использования хранилища ceph_pool_1

### Создаем API token для пользователя deploy_tf

### Секретный код api token копируем и используем далее к качестве одной из переменных в файле vars.tf

3. ## Настройка провайдера Terraform

### В качестве провайдера для Terraform при подключении к ProxMox используем плагин telmate/proxmox версии 3.0.1-rc4
Эту информацию указываем в файле main.tf

### Настройка подключения плагина telmate для ProxMox

```
terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}
```

4. ## Настройка Proxmox для деплоя вирт машин

### Для деплоя машин используем файл vars.tf и main.tf
В нашем случае будем создавать 2 вирт машины, чему соответствует параметр count = 2

5. ## Результат работы манифеста Terraform

### Проверяем корректность синтаксиcа командой
```terraform validate```

### Если ошибок не выявлено запускаем Terraform на создание вирт машин командой:
```terraform apply```

### Созданы две машины
vm-debian12-1
vm-debian12-2

С адресами 192.168.101.231 и 192.168.101.232 соответственно
