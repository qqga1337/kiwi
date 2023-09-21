# Install
```
kubectl create namespace argocd
```
```
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

```
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
```
argocd admin initial-password -n argocd
```
# Configure repos

```
argocd login 10.10.10.101
```

```
kubectl edit deployments.apps -n argocd argocd-repo-server 
```
```
spec:
  hostAliases:
  - hostnames:
    - gitlab.ds23.local
    ip: 10.10.10.100
```

```
kubectl delete pod -n argocd argocd-repo-server
```

```
argocd repo add https://gitlab.ds23.local/worker/shlyapa.git --username z --password z --insecure-skip-server-verification
```
