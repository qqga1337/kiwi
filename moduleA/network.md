# Работа с Eltex. Основные особенности и нюансы

Стандартный логин - admin
Стандартный пароль - password

Если в задании, например, ничего не будет про Firewall - или  ты не справился его настроить, расслабься и введи команду на интерфейсе - 

```
    ip firewall disable
```


Сделал дело?

Не забудь сохраниться тремя командами

```
    rtr1# commit
    rtr1# confirm
    rtr1# save

```


## Если интерфейсов не хватает

Как выяснилось, Eltex имеет проблемы с работой виртуальных интерфейсов, если например подключить virtio - он может его не отобразить в  команде 

```
    show interfaces status
```

Исправить это: 

```
rtr1# debug
rtr1(debug)#  show nic - покажет тебе список всех подключенных устройств, те что были определены неправильно будут называться virtio
rtr1(debug)# nic bind mac AA:BB:CC gigabitethernet 1/0/1 - прибиндили неопознанный virtio к g1/0/1, например
rtr1# commit
rtr1# confirm
rtr1# save
rtr1# reload system
```

После ребута твои virtio интерфейсы отлично привяжутся к GigabitEthernet

# Базовая настройка

## Поставить hostname

```
    vesr# configure terminal
    vesr(config)# hostname rtr1
```

## Создать пользователя с максимальными привилегиями 

```
    vesr# configure terminal
    vesr(config)# username digital
    vesr(config-user)#  password P@ssw0rd
    vesr(config-user)#  privilege 15

```


### Настройка NAT

Делается нетривиально, поехали

```
    vesr(config)# object-group network LOCAL1
    vesr(config-object-group-network)# ip prefix 10.10.2.0/24 - внутрення подсеть, которую планируешь натить
    vesr(config)# object-group network WAN1
    vesr(config-object-group-network)# ip address-range 192.168.122.100 - внешний адрес, в который планируешь натить
    vesr(config)# security zone UNTRUST
    vesr(config)# security zone TRUST
    vesr(config)# int g 1/0/1 - интерфейс в локальную сеть
    vesr(config-if)# security-zone TRUST 
    vesr(config)# int g 1/0/2 - интерфейс в локальную сеть
    vesr(config-if)# security-zone UNTRUST 
    vesr(config)# security zone-pair TRUST UNTRUST
    vesr(config-sec-zone-pair)# rule 1
    vesr(config-sec-zone-pair-rule)# action permit
    vesr(config-sec-zone-pair-rule)# match source-address LOCAL1
    vesr(config-sec-zone-pair-rule)# enable
    vesr(config)# nat source
    vesr(config-nat-source)# pool WAN1
    vesr(config-nat-source-pool)# ip address-range 192.168.122.100 - внешний адрес, в который планируешь натить
    vesr(config)# ruleset SNAT1
    vesr(config-ruleset)# to zone UNTRUST
    vesr(config-ruleset) rule 1
    vesr(config-ruleset-rule) match source-address LOCAL1
    vesr(config-ruleset-rule) action source-nat pool WAN1
    vesr(config-ruleset-rule) enable

```
Проверить можно:

```
    vesr# show ip nat translations
```

### Настройка  DHCP

Настройка специфическая
```
       vesr(config)#  ip dhcp-server - включили DHCP
       vesr(config)# ip dhcp-server  pool LOCAL - создали пул
       vesr(config-dhcp-server)#  network 10.10.2.0/24
       vesr(config-dhcp-server)#  address-range 10.10.2.2-10.10.2.10
       vesr(config-dhcp-server)# domain-name digital.skills
       vesr(config-dhcp-server)# default-router 10.10.2.1
       vesr(config-dhcp-server)# dns-server 10.113.38.100
       vesr(config)#  object-group service dhcp_server
       vesr(config-object-group)# port-range 67
       vesr(config)#  object-group service dhcp_client
       vesr(config-object-group)# port-range 68
       vesr(config)# security zone-pair TRUST self
       vesr(config-zone-pair)# rule 30
       vesr(config-zone-pair)# match protocol udp
       vesr(config-zone-pair)# match source-port dhcp_client
       vesr(config-zone-pair)# match destination-port dhcp_server
       vesr(config-zone-pair)# action permit
       vesr(config-zone-pair)# enable

```

Проверить можно:

```
    vesr# show ip dhcp server pool 
    vesr# show ip dhcp server pool LOCAL
```

### Настройка  GRE 

```
    vesr(config)# tunnel gre
    vesr(config-tunnel)# local address  или еще можно local interface - твой локальный адрес роутера для установки GRE  
    vesr(config-tunnel)# remote address 1.1.1.1
    vesr(config-tunnel)# ip address 10.5.5.1/30
    vesr(config-tunnel)# ip firewall disable или настрой security-zone (тут что больше нравится и подходит под условие задания)
    vesr(config-tunnel)# enable
```

### Настройка  GRE over IPSEC

Перед выполнением команд ниже, обязательно проверь, что у тебя работает GRE

```
    



```