#!/usr/bin/env bash

helm upgrade --install kube-state-metrics kube-state-metrics \
    --repo https://prometheus-community.github.io/helm-charts \
    --namespace kube-system \
    --wait \
    --timeout 10m

