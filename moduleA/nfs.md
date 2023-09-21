# Ставим nfs

Требования:

1. Должно быть свободно 60+гб на шаре
2. Статический адрес

Если доступно меньше 60гб -- делаем дополнительный диск и аттачим его к вмке

Дальше все просто -- режем, форматируем, монтируем

```
# fdisk /dev/vdb1
# g
# n 
# enter enter enter
# w
# mkfs.xfs /dev/vdb1
# mkdir /mnt/nfs
# vim /etc/fstab
# /dev/vdb1 /mnt/nfs xfs defaults 0 0
# mount -av
```

Ставим NFS

Для деб -- `apt install nfs-kernel-server`

Для рпм -- `dnf install nfs-utils`

Настраиваем права

```
# chown 36:36 /mnt/nfs
# chmod 0775 /mnt/nfs
```

Добавляем в /etc/exports строчку типа `/mnt/nfs *(rw,anonuid=36,anongid=36)`

Перезапускаем все на свете

```
# systemctl enable nfs-server
# systemctl enable rpcbind
# systemctl enable nfs-blkmap
# systemctl restart nfs-server
# systemctl restart rpcbind
# systemctl restart nfs-blkmap
```

Если мы разворачиваем сторадж прям на ноде -- надо еще сделать так

```
# groupadd sanlock -g 179
# groupadd kvm -g 36
# useradd sanlock -u 179 -g 179 -G kvm
# useradd vdsm -u 36 -g 36 -G sanlock
```