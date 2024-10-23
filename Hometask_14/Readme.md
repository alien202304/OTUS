### Установка Ceph кластер ###

Клонируем 8-ю версию плейбука для Ceph

```git clone https://github.com/ceph/ceph-ansible```

Проверяем версию клонированного репозитория

```git checkout stable-8.0```

Устанавливаем необходимые пакеты Python3

```apt install python3-pip```

Добавляем необходимые зависимости

```
# pip install -r requirements.txt
# ansible-galaxy install -r requirements.yml
```

Создаем в папке ceph-ansible каталог для перечисления узлов кластера и их настроек

```
# mkdir inventory && cd inventory
```

Coздаем в вышесозданной папке файл hosts c таким содержимым:
```
[mons]
ceph01 monitor_address=10.10.201.131
ceph02 monitor_address=10.10.201.132
ceph03 monitor_address=10.10.201.133

[osds]
ceph01
ceph02
ceph03

[mgrs]
ceph01
ceph02
ceph03

[mdss]
ceph01
ceph02
ceph03

[monitoring]
ceph01
ceph02
ceph03
```
где все три ноды используются и для размещения мониторов и для osd дисков. Адреса нод соответствуют адресному пространству кластерной сети Ceph, созданной ранее.

Каталоге group_vars задаем требуемые параметры нашего кластера в файл all.yml

```
ceph_origin: repository
ceph_repository: community
ceph_stable_release: reef  # последний стабильный релиз Ceph
public_network: "192.168.101.0/24"
cluster_network: "10.10.201.0/24"
cluster: ceph

osd_objectstore: bluestore

ntp_service_enabled: true
ntp_daemon_type: chronyd

dashboard_enabled: True
dashboard_protocol: http
dashboard_admin_user: admin
dashboard_admin_password: p@ssw0rd

grafana_admin_user: admin
grafana_admin_password: p@ssw0rd

ceph_conf_overrides:
  global:
    osd_pool_default_pg_num: 64
    osd_journal_size: 5120
    osd_pool_default_size: 3
    osd_pool_default_min_size:  2

```


