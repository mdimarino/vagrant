#!/usr/bin/env bash

# https://github.com/kubernetes-sigs/metrics-server

# https://artifacthub.io/packages/helm/metrics-server/metrics-server

helm upgrade --install metrics-server metrics-server \
    --repo https://kubernetes-sigs.github.io/metrics-server/ \
    --namespace kube-system \
    --set replicas=2 \
    --set args={'--kubelet-insecure-tls=true'} \
    --wait \
    --timeout 10m
