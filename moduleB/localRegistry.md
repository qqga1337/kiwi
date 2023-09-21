```
docker run -d --restart=always --name registry -v /root/certs:/certs -e REGISTRY_HTTP_ADDR=0.0.0.0:443 -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/newcert.pem -e REGISTRY_HTTP_TLS_KEY=/certs/newkey.pem -p 443:443 registry:2
```
```
docker tag reg.ds23.local/app
```
```
docker push reg.ds23.local/app
```
```
docker pull
```
