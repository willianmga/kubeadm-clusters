# Kubernetes Clusters with kubeadm

## Kubeadm Requirements

Updated requirements available [here](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin)

* A compatible Linux host. The Kubernetes project provides generic instructions for Linux distributions based on Debian and Red Hat, and those distributions without a package manager.
* 2 GB or more of RAM per machine (any less will leave little room for your apps).
* 2 CPUs or more.
* Full network connectivity between all machines in the cluster (public or private network is fine).
* Unique hostname, MAC address, and product_uuid for every node. See here for more details.
* Certain ports are open on your machines. See below for details
* sudo and ssh access on each of the nodes

## Prepare

### Install Dependencies

Kubernetes requires the following
* Container runtime (examples uses containerd)
* Container Networking Interface (CNI) plugin running (examples uses weavenet)
* Kubeadm
* Kubelet
* Kubectl

Official Docs
* [Kubeadm installation guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
* [Container Runtime installation guide](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)

### Configure

* Disabled memory Swap. You MUST disable swap in order for the kubelet to work properly.
* Configure the container runtime and kubelet to use the appropriate cgroup driver
* Load overlay and br_netfilter network modules on linux

### Allow Ports

Control plane
* TCP	Inbound	6443	Kubernetes API
* TCP	Inbound	2379-2380	etcd server client API
* TCP	Inbound	10250	Kubelet API
* TCP	Inbound	10259	kube-scheduler
* TCP	Inbound	10257	kube-controller-manager

Worker node(s)
* TCP	Inbound	10250	Kubelet API
* TCP	Inbound	30000-32767	NodePort Services

All nodes
* TCP   Inbound 6783    Weavenet CNI Plugin
* UDP   Inbound 6783-6784 Weavenet CNI Plugin

