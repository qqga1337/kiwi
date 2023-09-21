#######  Настройка CDIT.DIGITSL.RU  ##########
hostnamectl set-hostname cgit.digital.ru
echo "127.0.0.1 cgit.digital.ru cgit" >> /etc/hosts
#Устанавливаем Docker
apt install docker.io

# Скачиваем и устанавливаем docker-compose
wget https://github.com/docker/compose/releases/download/v2.11.0/docker-compose-linux-x86_64
chmod +x docker-compose-linux-x86_64
mv docker-compose-linux-x86_64 /bin/docker-compose
#Создаем каталог для файлов gitlab
mkdir /opt/gitlab
#Создаем файл docker-compose
cat > docker-compose.yml <<EOF
# docker-compose.yml
version: '3.7'
services:
  web:
    image: 'gitlab/gitlab-ce:latest'
    restart: always
    hostname: 'localhost'
    container_name: gitlab-ce
    ports:
      - '5000:5000'
      - '80:80'
      - '443:443'
    volumes:
      - '/opt/gitlab/config:/etc/gitlab'
      - '/opt/gitlab/logs:/var/log/gitlab'
      - '/opt/gitlab/data:/var/opt/gitlab'
    networks:
      - gitlab
  gitlab-runner:
    image: gitlab/gitlab-runner
    container_name: gitlab-runner    
    restart: always
    depends_on:
      - web
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - '/opt/gitlab/gitlab-runner:/etc/gitlab-runner'
    networks:
      - gitlab
networks:
  gitlab:
    name: gitlab-network
EOF

#запускаем, идем выпускать серты.
docker-compose up -d

#Создаем запрос сертификата
openssl req -newkey rsa:2048 -keyout cgit.key -out cgit.csr
#Сразу убираем пароль с ключа:
openssl rsa -in cgit.key -out cgit.key
# Берем запрос, идем на FreeIPA и выпускаем сертификат. Выпущенный сертификат кладем сюда, именуем cgit.pem. C FreeIPA берем СА сертификат, называем digital.ru.crt. Создаем A запись, создаем пользователя gitlab
# Создаем бандл сертификатов
cat digital.ru.crt cgit.pem > ca.crt
# Останавливаем docker-compose, идем править конфиги
# кладем серты в gitlab-runner
mkdir -p /opt/gitlab/gitlab-runner/certs
cp ca.crt gitlab/gitlab-runner/certs/cgit.digital.ru.crt
#кладем серты в gitlab-ce
cp cgit.key /opt/gitlab/config/cgit.key
cp cgit.pem /opt/gitlab/config/cgit.pem

#Правим кофиг gitlab-ce:
cat > gitlab/config/gitlab.rb <<EOF
external_url 'https://cgit.digital.ru'
gitlab_rails['ldap_enabled'] = true
gitlab_rails['prevent_ldap_sign_in'] = false
gitlab_rails['ldap_servers'] = YAML.load_file('/etc/gitlab/freeipa_settings.yml')
registry_external_url 'https://cgit.digital.ru:5000'
 gitlab_rails['registry_enabled'] = true
 gitlab_rails['registry_host'] = "cgit.digital.ru"
 gitlab_rails['registry_port'] = "5050"
 gitlab_rails['registry_path'] = "/var/opt/gitlab/gitlab-rails/shared/registry"
 registry['enable'] = true
 registry['registry_http_addr'] = "0.0.0.0:5050"
 registry['debug_addr'] = "localhost:5001"
 registry['env'] = {
   'SSL_CERT_DIR' => "/etc/gitlab/ssl/"
 }
registry['rootcertbundle'] = "/etc/gitlab/ca.crt"
nginx['redirect_http_to_https'] = true
nginx['ssl_certificate'] = "/etc/gitlab/cgit.pem"
nginx['ssl_certificate_key'] = "/etc/gitlab/cgit.key"
 nginx['listen_addresses'] = ['*', '[::]']
 nginx['listen_port'] = 443
 nginx['listen_https'] = true
registry_nginx['enable'] = true
registry_nginx['listen_port'] = 5000
registry_nginx['ssl_certificate'] = "/etc/gitlab/cgit.pem"
registry_nginx['ssl_certificate_key'] = "/etc/gitlab/cgit.key"
EOF
# Сразу же прикручиваем доменную авторизацию
cat > gitlab/config/freeipa_settings.yml <<EOF
main: 
  label: 'FreeIPA'
  host: 'digital.ru'
  port: 389
  uid: 'uid'
  method: 'tls'
  bind_dn: 'uid=gitlab,cn=users,cn=accounts,dc=example,dc=com'
  password: 'P@ssw0rd'
  encryption: 'plain'
  base: 'cn=accounts,dc=digital,dc=ru'
  verify_certificates: false
  attributes:
    username: ['uid']
    email: ['mail']
    name: 'displayName'
    first_name: 'givenName'
    last_name: 'sn'
    confirm : 'no'
EOF

#Конфиг для Runner, token взять с веб интерфейса
cat > gitlab/gitlab-runner/config.toml <<EOF
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "runner-number-one"
  url = "https://cgit.digital.ru"
  id = 1
  token = "***********"
  executor = "docker"
  [runners.custom_build_dir]
  [runners.docker]
    tls_verify = false
    image = "docker:20.10.16"
    privileged = true
#    cache_dir = "cache"
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/var/run/docker.sock:/var/run/docker.sock","/cache"]
  [runners.cache]
    Insecure = false
EOF

