## gcpとedgeのハイブリッド k8s　cluster 構築手順
本手順を実行する前に下記条件を揃う必要があります。
- gceのfirewallに関連ポート開け済み
- gce側でのopenvpn-serverの構築済み
- edge側でのopenvpn-clientの構築済み
- セキュリティためのfirewallの上がり通信のIP限定設定

## gcp,edge　共通作業
```shell
# k8s install
sudo swapoff -a
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

sudo apt update && sudo apt install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt update && sudo apt install -y kubelet kubeadm kubectl
sudo apt show kubelet kubeadm kubectl
```

## gcp側での作業
```shell
# kube master が使用するipを変更

# openvpnのtun0(nic)のIPを指定してk８sを構築
ip a | grep tun0
# inet x.x.x.x　のIPをメモリます。

sudo vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```
```text
# 変更前
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# 変更後　メモったIPを下記設定に追加
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml --node-ip=10.0.0.1"
```
```shell
# master node 起動
sudo kubeadm init --pod-network-cidr=10.244.0.0/16  --apiserver-advertise-address=10.0.0.1 --apiserver-cert-extra-sans=10.0.0.1
# 出力されたjoinコマンドをコピーします。
# 例:kubeadm join 10.0.0.1:6443 --token ew5th5.ss0waj1eq80s5ohu --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxx


# api操作token取得
mkdir $HOME/.kube/ 
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# deployments/kube-flannel.ymlをデプロイ
sudo kubectl apply -f deployments/kube-flannel.yml

# master node にpodがデプロイできるように設定
kubectl taint nodes aion-cloud node-role.kubernetes.io/master:NoSchedule-
```


## edge側での作業
```shell
# kube client が使用するipを変更

# openvpnのtun0(nic)のIPを指定してk８sを構築
ip a | grep tun0
# inet x.x.x.x　のIPをメモリます。

sudo vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```
```text
# 変更前
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# 変更後　メモったIPを下記設定に追加
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml --node-ip=10.0.0.6"
```

```shell
# k8s master　側でメモったjoin　コマンドを実行
# 例: 
sudo kubeadm join 10.0.0.1:6443 --token ew5th5.ss0waj1eq80s5ohu --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxx
```

## gceとedgeのk8s cluster以上で構築完了
```shell
# master node にて ノード一覧を確認
kubectl get node -o wide
```
