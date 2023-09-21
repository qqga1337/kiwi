# Deploy gitlab with self-signed certs

vim /etc/ssl/openssl.cnf
```
dir ./demoCA > /etc/ca
uncomment copy_extentions = copy
policy policy_match > policy_anything
```

vim /usr/lib/ssl/misc/CA.pl
```
CATOP change to /etc/ca
```

cd /usr/lib/ssl/misc
```
CA.pl -newca
!!!CN!!! = demo.local 
```

google openssl alternative names 1 link
```
openssl req -new -sha256 -nodes -out newreq.pem -newkey rsa:2048 -keyout newkey.pem -config <(
cat <<-EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=US
ST=New York
L=Rochester
O=End Point
OU=Testing Domain
CN = gitlab.popa.com

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = gitlab.popa.com
DNS.2 = popa.popa.com
DNS.3 = 10.10.10.100
EOF
)
```
```
cp newkey.pem newcert.pem /usr/lib/ssl/misc/
```
```
./CA.pl -sign
```


```
export GITLAB_HOME=/srv/gitlab
```

create docker-compose.yml
```
version: '3.6'
services:
  web:
    image: 'gitlab/gitlab-ee:latest'
    restart: always
    hostname: 'gitlab.popa.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url   'https://gitlab.popa.com'
        letsencrypt['enable'] = false
        registry_external_url  'https://gitlab.popa.com:5050'
        registry_nginx['ssl_certificate'] = "/etc/gitlabcer/newcert.pem"
        registry_nginx['ssl_certificate_key'] = "/etc/gitlabcer/newkey.pem"
        nginx['ssl_certificate'] = "/etc/gitlabcer/newcert.pem"
        nginx['ssl_certificate_key'] = "/etc/gitlabcer/newkey.pem"
        # Add any other gitlab.rb configuration here, each on its own line
    ports:
      - '80:80'
      - '443:443'
      - '5050:5050'
      - '22:22'
    volumes:
      - '/etc/gitlabcer:/etc/gitlabcer' 
      - '$GITLAB_HOME/config:/etc/gitlab'
      - '$GITLAB_HOME/logs:/var/log/gitlab'
      - '$GITLAB_HOME/data:/var/opt/gitlab'
    shm_size: '256m'

```

```
docker-compose up -d
```

if work - we will see state "healthy"

to get password use this command and save password somewhere 
```
docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```
