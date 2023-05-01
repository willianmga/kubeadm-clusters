# setup.sh script

Example script on how to setup a non high-availability kubernetes cluster with kubeadm.

Required S.O: 
- Debian/Ubuntu

Architecture:
- amd64

## Setup cluster

### Setup controlplane

a) create the controlplane node
```shell
cat <<EOF | tee kubeadm.conf
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF
```

```shell
kubeadm init --config kubeadm.conf
```

will output:

```shell
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a Pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  /docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

b) setup kubectl

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

c) install cni plugin

```shell
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

### Join worker nodes

```shell
kubeadm join 10.154.0.13:6443 --token 9vedgk.2jv3506iqkr6ra0d --discovery-token-ca-cert-hash sha256:95a171ad44864804fa0d21e0159ee95ae34d9b7bd7a635a71611fd2d4591c4b3
```