# Создание отказоустойчивого кластера PostgreSQL + Patroni #
### Схема реализации отказойстойчивого кластера PostgreSQL приведена на рисунке ниже ###
![Схема PostgreSQL_Patroni_cluster](https://github.com/user-attachments/assets/b2dfcd83-c23f-4458-b3fa-abfecf1cc105)


### Исходные данные ###
Для создания кластера использованы три VM под управлением Ubuntu 20.04
- node1 192.168.101.191
- node2 192.168.101.192
- node3 192.168.101.193

Обращение к базам данных PostgreSQL через виртуальный IP адрес:
vIP 192.168.101.185

# Создание etcd кластера #

### Добавляем на все три ноды кластера информацию в файл  ###

```/etc/hosts```

```
$ sudo vim /etc/hosts
127.0.0.1 localhost node1
192.168.101.191 node1
192.168.101.192 node2
192.168.101.193 node3
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
### Добавляем к кластеру, развернутому на node1 два узла node2 и node3 ###

```sudo etcdctl member add node2 http://192.168.101.192:2380```

```sudo etcdctl member add node3 http://192.168.101.193:2380```

### Пеерезапускаем сервис etcd на всех 3 нодах и проверяем состояние кластера etcd ###

```sudo systemctl restart etcd```

```$ sudo etcdctl member list```

```$ sudo etcdctl cluster-health```

Результаты проверки в соответствующих файлах приложены


