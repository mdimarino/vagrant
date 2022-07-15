#!/usr/bin/env bash

### https://kubernetes.github.io/ingress-nginx/ ###

helm upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --create-namespace \
    --namespace ingress-nginx \
    --set controller.hostNetwork=true,controller.hostPort.enabled=true,controller.kind=DaemonSet \
    --wait \
    --timeout 10m

