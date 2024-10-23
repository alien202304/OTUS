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
