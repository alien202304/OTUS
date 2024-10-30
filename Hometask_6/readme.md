# Создание отказоустойчивого кластера PostgreSQL + Patroni #
### Схема реализации отказойстойчивого кластера PostgreSQL приведена на рисунке ниже ###
![Схема PostgreSQL_Patroni_cluster](https://github.com/user-attachments/assets/f864cf5b-fab0-47ac-b7ff-48015cb46116)

### Исходные данные ###
Для создания кластера использованы три VM под управлением Ubuntu 20.04
- node1 192.168.101.181
- node2 192.168.101.182
- node3 192.168.101.183

Обращение к базам данных PostgreSQL через виртуальный IP адрес:
vIP 192.168.101.185

# Создание etcd кластера #

### Добавляем на все три ноды кластера информацию в файл  ###

```/etc/hosts```

```
$ sudo vim /etc/hosts
127.0.0.1 localhost node1
192.168.101.181 node1
192.168.101.182 node2
192.168.101.183 node3
```

### Установка необходимых пакетов с помощью команды ###

```sudo apt-get install etcd```

### Настройка конфигурационных файлов ###

```$ sudo vim /etc/default/etcd```

Для узла node1:
```
ETCD_NAME=node1
ETCD_INITIAL_CLUSTER="node1=http://192.168.101.191:2380"
ETCD_INITIAL_CLUSTER_TOKEN="devops_token"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.101.191:2380"
ETCD_DATA_DIR="/var/lib/etcd/postgresql"
ETCD_LISTEN_PEER_URLS="http://192.168.101.191:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.101.191:2379,http://localhost:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.101.191:2379"
```
Для узла node2:
```
ETCD_NAME=node2
ETCD_INITIAL_CLUSTER="node1=http://192.168.101.191:2380,node2=http://192.168.101.192:2380"
ETCD_INITIAL_CLUSTER_TOKEN="devops_token"
ETCD_INITIAL_CLUSTER_STATE="existing"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.101.192:2380"
ETCD_DATA_DIR="/var/lib/etcd/postgresql"
ETCD_LISTEN_PEER_URLS="http://192.168.101.192:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.101.192:2379,http://localhost:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.101.192:2379"
```

Для узла node3:
```
ETCD_NAME=node3
ETCD_INITIAL_CLUSTER="node1=http://192.168.101.191:2380,node2=http://192.168.101.192:2380,node3=http://192.168.101.193:2380"
ETCD_INITIAL_CLUSTER_TOKEN="devops_token"
ETCD_INITIAL_CLUSTER_STATE="existing"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.101.193:2380"
ETCD_DATA_DIR="/var/lib/etcd/postgresql"
ETCD_LISTEN_PEER_URLS="http://192.168.101.193:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.101.193:2379,http://localhost:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.101.193:2379"
```
