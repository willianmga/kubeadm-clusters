#!/bin/bash

# Remove controlplane node taint
kubectl taint node kube-controlplane node-role.kubernetes.io/control-plane:NoSchedule-

# Optimized for Kubernetes v1.17.1

# WeaveNet CNI
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# NGINX Ingress Controller v1.7.1 
https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.1/deploy/static/provider/cloud/deploy.yaml

# Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.3/components.yaml
