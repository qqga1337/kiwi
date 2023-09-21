# HPA

1. Надо поставить metrics server. Вроде его умеет ставить кубспрей, но это не точно.

Должна работать команда `kubectl top pods -n kube-system`. Если не работает -- metrics server не установлен.

На всякий

https://www.linuxtechi.com/how-to-install-kubernetes-metrics-server/

Скачать metrics-server можно вот так

`wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml`

Дальше надо открыть этот файл, найти деплоймент и долистать до секции args

В args дописываем вниз

`- --kubelet-insecure-tls`

Далее листаем до секции spec 

В spec дописываем сверху 

`hostNetwork: true`

Потом накатываем этот файл через `kubectl apply -f`

2. В манифесте приложухи обязательно указываем реквесты и лимиты, типа так. Это делается в спеках в темплейте

```
       resources:
         limits:
           cpu: 500m
         requests:
           cpu: 200m
```

3. Создаем манифест для HPA

```
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
 name: ds23-hpa
spec:
 scaleTargetRef:
   apiVersion: apps/v1
   kind: Deployment
   name: rea23-app #Тут имя приложухи, также как оно называется в деплойменте
 minReplicas: 1  #Сколько минимум реплик будет. То есть сколько реплик будет всегда гарантированно
 maxReplicas: 10  #Сколько максимум реплик будет. То есть до какого значения реплик можно расширятся
 targetCPUUtilizationPercentage: 50 #Триггер для расширения -- утилизация больше 50% озу
```

Еще hpa можно создать вот такой командочкой, если лениво писать ямлик

`kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10`

Проверить можно `kubectl get hpa`
