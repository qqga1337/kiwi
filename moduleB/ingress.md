# Ingress https

## ВАЖНО

- Целевой сервис должен быть ClusterIP, а не LoadBalancer

1. Сделали серт обязательно с альтами, это очень важно

2. Сделали секрет из серта

`kubectl create secret tls ingress-ssl --key newkey.pem --cert newcert.pem`

3. Делаем ингресс манифест

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rea23-app
  namespace: default
spec:
  ingressClassName: nginx  #Всегда nginx
  tls:
  - hosts:
    - app.ds23.local     #Тут пишем имя, на которое будем вешать серт
    secretName: ingress-ssl   # Тут имя секрета с сертом
  rules:
  - host: "app.ds23.local"  #Доступ будет только по этому имени, надо зарегать его в DNS
    http:
      paths:
        - pathType: Prefix
          path: "/"
          backend:
            service:
              name: rea23-app
              port:
                number: 6543  #Тут порт сервиса
```

# Дружим nginx с metallb

Надо накатить игресс вот такой командой

`kubectl apply -n ingress-nginx -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.2.0/deploy/static/provider/cloud/deploy.yaml`

Сделать это надо поверх того ингресса, который ставит кубспрей

Еще, после того, как создали пул, надо создать адвертисмент, иначе не сможешь зайти на ингрес ниоткуда кроме кластера

`vim adv.yaml`

```
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example                #Любое название
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool      #Название созданного пула
```

После создания ingress должен появится controller-service. Нужно сделать `kubectl edit` и привести сервис к следующему виду

```
apiVersion: v1
kind: Service
metadata:
  name: nginx
  annotations:
    metallb.universe.tf/address-pool: first-pool #цепляем пул
    metallb.universe.tf/loadBalancerIPs: 10.10.10.200  #Дописываем аннотацию с адресом, который нам нужен
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
  type: LoadBalancer   #Тип меняем на LoadBalancer
```

После этого ingress вполне дружится с metallb. Пул с таким адресом конечно же должен существовать


# Выключаем hsts

Делаем `kubectl get cm -n ingress-nginx`

Там должна быть cm ingress-nginx-controller

редактируем ее, в data дописываем 

```
data:
 ...
 hsts: "false"
```

Перезапускаем ingress

```
kubectl rollout -n ingress-nginx restart deployment ingress-nginx-controller
```


Отключаем https редирект

В ту же конфигу, где отключали hsts дописываем

```
data:
  ssl-redirect: "false"
```

Потом перезапускаем
