#!/usr/bin/env bash

kubectl apply -f 01-namespace.yaml
kubectl apply -f 02-clusterRole.yaml
kubectl apply -f 03-config-map.yaml
kubectl apply -f 04-prometheus-deployment.yaml
kubectl apply -f 05-prometheus-service.yaml
kubectl apply -f 06-prometheus-ingress.yaml
