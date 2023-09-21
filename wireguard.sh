#### WireGuard LRTR  #####

# Устанавливаем WireGuard
apt install wireguard
# Подключаем модули ядра WireGuard
modprobe wireguard
# Создаем приватный ключ
echo "aKvIundEFCplDZzW+K+xebyj1I/tS1eHwIQnV+LEzEw=" > /etc/wireguard/privatekey 
# Создаем Публичный ключ
echo "ILV9zHII224tr+pk69H6SsM06+EWzDvFUdyxK7MIggo=" > /etc/wireguard/publickey 
# Создаем конфигурационный файл
cat > /etc/wireguard/wg0.conf  <<EOF
[Interface]
Address = 172.16.1.2/24
PrivateKey = aKvIundEFCplDZzW+K+xebyj1I/tS1eHwIQnV+LEzEw=

[Peer]
PublicKey = WbkKz0hE6dXYSzsSGag5ywYm61IVrqdrH2tff/UpaAk= 
AllowedIPs = 10.1.2.0/24,172.16.1.0/24
EndPoint = 192.168.122.155:51820
PersistentKeepAlive = 5
EOF
# Запускаем службу WG и ставим ее в автозапуск
systemctl enable --now wg-quick@wg0
# Смотрим статус подключения
wg show wg0
# Если не прокатило: wg genkey | tee /etc/wireguard/privatekey | wg pubkey | tee /etc/wireguard/publickey

# WireGuard CRTR

# Устанавливаем WireGuard
apt install wireguard
# Подключаем модули ядра WireGuard
modprobe wireguard
# Создаем приватный ключ
echo "GDB6RVAu02VPK71WW86v915ubcTkkZHE8Kq2g+nlAG0=" > /etc/wireguard/privatekey 
# Создаем Публичный ключ
echo "WbkKz0hE6dXYSzsSGag5ywYm61IVrqdrH2tff/UpaAk=" > /etc/wireguard/publickey 
# Создаем конфигурационный файл
cat > wg0.conf <<EOF
[Interface]
ListenPort = 51820
Address = 172.16.1.1/24
PrivateKey = GDB6RVAu02VPK71WW86v915ubcTkkZHE8Kq2g+nlAG0= 

[Peer]
PublicKey = ILV9zHII224tr+pk69H6SsM06+EWzDvFUdyxK7MIggo=
AllowedIPs = 10.1.1.0/24,172.16.1.0/24
PersistentKeepAlive = 5
EOF

# Запускаем службу WG и ставим ее в автозапуск
systemctl enable --now wg-quick@wg0
# Смотрим статус подключения
wg show wg0
# Если не прокатило: wg genkey | tee /etc/wireguard/privatekey | wg pubkey | tee /etc/wireguard/publickey

