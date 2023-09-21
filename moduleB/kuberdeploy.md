# 1. Install containerd,runc,cni,crictl,kubelet,kubectl,kubeadm on debian 11

   **Install сontainerd**
   
   ```
   apt update && apt install vim curl
   ```   
   ```
   wget https://github.com/containerd/containerd/releases/download/v1.7.5/containerd-1.7.5-linux-amd64.tar.gz
   ```
   ```
   tar Cxzvf /usr/local containerd-1.7.5-linux-amd64.tar.gz
   ```
   ```
   curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service
   ```
   ```
   systemctl daemon-reload
   systemctl enable containerd
   systemctl start containerd
   ```


   **Install runc**

   ```
   wget https://github.com/opencontainers/runc/releases/download/v1.1.9/runc.amd64
   ```
   ```
   install -m 755 runc.amd64 /usr/local/sbin/runc
   ```

   **Install CNI**
   
   ```
   wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
   ```
   ```
   mkdir -p /opt/cni/bin
   ```
   ```
   tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.3.0.tgz
   ```
   
   **Install crictl**
   
   ```
   wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.28.0/crictl-v1.28.0-linux-amd64.tar.gz
   ```
   ```
   tar zxvf crictl-v1.28.0-linux-amd64.tar.gz -C /usr/local/bin
   ```
   ```
   crictl img #проверяем, что все ок
   ```

   **Install kubelet, kubectl, kubeadm**
   
   ```
   apt install -y apt-transport-https ca-certificates cgpg
   ```
   ```
   curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
   ```
   ```
   echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
   ```
   ```
   apt update
   ```
   ```
   apt install -y kubelet kubeadm kubectl
   ```
# 2. Init cluster

   ```
   echo 10.10.10.21 k8s-master-1 > /etc/hosts
   ```
   ```
   swapoff -a
   ```
   ```
   modprobe br_netfilter
   ```
   ```
   sysctl -w net.bridge.bridge-nf-call-iptables=1
   ```
   ```
   sysctl -w net.ipv4.ip_forward=1
   ```
   ```
   kubeadm init --pod-network-cidr=192.168.0.0/16
   ```
   Далее следовать инструкции после удачной инициализации кластера

# 3. Install and deploy calico

   ```
   curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml -O
   ```
   ```
   kubectl apply -f calico.yaml
   ```
   ```
   kubectl get nodes
   # Должен быть статус Ready
   ```
