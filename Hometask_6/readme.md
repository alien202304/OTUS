# Создание отказоустойчивого кластера PostgreSQL + Patroni #
### Схема реализации отказойстойчивого кластера PostgreSQL приведена на рисунке ниже ###
![Схема PostgreSQL_Patroni_cluster](https://github.com/user-attachments/assets/b2dfcd83-c23f-4458-b3fa-abfecf1cc105)


### Исходные данные ###
Для создания кластера использованы три VM под управлением Ubuntu 20.04
- node1 192.168.101.191
- node2 192.168.101.192
- node3 192.168.101.193

Обращение к базам данных PostgreSQL через виртуальный IP адрес:
vIP 192.168.101.195

На всех трех узлах выполняем установку минимально необходимых пакетов:

```
apt update && apt upgrade -y
apt install htop sudo vim -y
```

# Создание etcd кластера #
На всех трех нодах установливаем версию etcd, доступную из стандартного репозитория Ubuntu:

### Добавляем на все три ноды кластера информацию в файл  ###

```/etc/hosts```

Ниже конфиг для node1, для остальных 2 узлов конфиг такой же, за исключением первой строки, где надо изменить node1 на node2 и node3 соответственно:
```
$ sudo vim /etc/hosts
127.0.0.1 localhost node1
192.168.101.191 node1
192.168.101.192 node2
192.168.101.193 node3
```

### Установка необходимых пакетов с помощью команды ###

```$ sudo apt-get install etcd```

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
### Добавляем к кластеру etcd, развернутому на node1, два узла: node2 и node3 ###

```$ sudo etcdctl member add node2 http://192.168.101.192:2380```

```$ sudo etcdctl member add node3 http://192.168.101.193:2380```

### Пеерезапускаем сервис etcd на всех 3 нодах и проверяем состояние кластера etcd ###

```$ sudo systemctl restart etcd```

```$ sudo etcdctl member list```

```$ sudo etcdctl cluster-health```

Результаты проверки в соответствующих файлах приложены

# Установка PostgreSQL #
Устанавливаем Percona для PostgreSQL 

```
sudo apt-get update -y; sudo apt-get install -y wget gnupg2 lsb-release curl
wget https://repo.percona.com/apt/percona-release_latest.generic_all.deb
sudo dpkg -i percona-release_latest.generic_all.deb
sudo apt-get update
sudo percona-release setup ppg-12
sudo apt-get install percona-postgresql-12
```
Установка производится на всех 3 узлах кластера.

# Установка Patroni #

```$ sudo apt-get install percona-patroni```

Конфигурационный файл ```/etc/patroni/config.yml``` для узла node1 приведен в файле config.yml

# Установка HAproxy ###
Используем виртуальный адрес haproxy кластера ```192.168.101.195``` для балансировки запросов к базе данных PostgreSQL и обеспечения отказоустойчивости.
Для разделения запросов на чтение и запись будем использовать два разных порта:
+ Запросы на запись (Writes)  → 5000
+ Запросы на чтение (Reads)   → 5001
  
Для установки haproxy на всех трех узлах выполняем:

```$ sudo apt-get install haproxy```

### Настраиваем основной файл конфигурации следующим образом: ###

```
$ vim /etc/haproxy/haproxy.cfg
global
    maxconn 100

defaults
    log    global
    mode    tcp
    retries 2
    timeout client 30m
    timeout connect 4s
    timeout server 30m
    timeout check 5s

listen stats
    mode http
    bind *:7000
    stats enable
    stats uri /

listen primary
    bind *:5000
    option httpchk OPTIONS /master
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server node1 node1:5432 maxconn 100 check port 8008
    server node2 node2:5432 maxconn 100 check port 8008
    server node3 node3:5432 maxconn 100 check port 8008

listen standbys
    balance roundrobin
    bind *:5001
    option httpchk OPTIONS /replica
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server node1 node1:5432 maxconn 100 check port 8008
    server node2 node2:5432 maxconn 100 check port 8008
    server node3 node3:5432 maxconn 100 check port 8008
```
