# Deploy kubespray

Configure master node

```
apt update
apt install git python3 python3-pip sudo -y
git clone https://github.com/kubernetes-incubator/kubespray.git
cd kubespray
pip install -r requirements.txt
```

create host inventory

```
cp -rfp inventory/sample inventory/mycluster
```

ip counts depends from counts of nodes
```
declare -a IPS=(x.x.x.x x.x.x.x)
```

use python script to create inventory
```
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```

check thats all alright
```
vim inventory/mycluster/hosts.yaml
```
next step we need to review inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml and change this:
```
kube_version: v1.26.2
kube_network_plugin: calico
cluster_name: popa.local (doljno otlichatsya ot nazvania domena tvoego) 
```

inventory/mycluster/group_vars/k8s_cluster/addons.yml
```
dashboard_enabled: true
ingress_nginx_enabled: true
ingress_nginx_host_network: true
metallb: true
```
copy ssh keys
```
ssh-keygen
ssh-copy-id root@node1,2,3,4,5,6..
```

deploy
```
cd kubespray
```

enable forwarding and disable swap
```
ansible all -i inventory/mycluster/hosts.yaml -m shell -a "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf"
ansible all -i inventory/mycluster/hosts.yaml -m shell -a "sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab && sudo swapoff -a"
```

now we can deploy kubernetes cluster
```
ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-user=root cluster.yml
```

it can takes 20-30 minutes //depends from ur internet speed

in the end if all ok - we will see all nodes in state "Ready"
