#!/bin/bash

# For installation of kubeadm into Ubuntu with amd64 processors

setup_host_firewall() {

    # Forwarding IPv4 and letting iptables see bridged traffic
    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter

    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

    sudo sysctl --system

    # verify

    lsmod | grep br_netfilter
    lsmod | grep overlay
    sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

}

install_container_runtime() {

    # Install ContainerD

    CONTAINERD_VERSION="1.6.20"
    RUNC_VERSION="1.1.5"
    CNI_PLUGINS_VERSION="1.2.0"

    ## containerd
    wget "https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz"
    tar Cxzvf /usr/local "containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz"

    # runc
    wget "https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64"
    install -m 755 runc.amd64 /usr/local/sbin/runc

    # cni plugins
    wget "https://github.com/containernetworking/plugins/releases/download/v${CNI_PLUGINS_VERSION}/cni-plugins-linux-amd64-v${CNI_PLUGINS_VERSION}.tgz"
    mkdir -p /opt/cni/bin
    tar Cxzvf /opt/cni/bin "cni-plugins-linux-amd64-v${CNI_PLUGINS_VERSION}.tgz"

    # start containerd with systemd
    wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
    mkdir -p /usr/local/lib/systemd/system
    mv containerd.service /usr/local/lib/systemd/system/containerd.service

    systemctl daemon-reload
    systemctl enable --now containerd

    # use systemd cgroup driver

    mkdir -p /etc/containerd/
    containerd config default > /etc/containerd/config.toml
    sed -i -e 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
    systemctl restart containerd
}

install_kubernetes_tools() {

    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl

}

# For reference only. Needed only when installing controlplane node
install_cni_plugin() {
    kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
}

run_kubeadm_init() {

    # use systemd as kubelet cgroup driver
    cat <<EOF | tee kubeadm.conf
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF

    kubeadm init --config kubeadm.conf

}

setup_host_firewall
install_container_runtime
install_kubernetes_tools
