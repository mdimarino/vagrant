#!/usr/bin/env bash

### https://metallb.universe.tf/ ###

helm upgrade --install metallb metallb \
    --repo https://metallb.github.io/metallb \
    --create-namespace \
    --namespace metallb-system \
    --wait \
    --timeout 10m

kubectl apply -f layer-2-config.yaml

