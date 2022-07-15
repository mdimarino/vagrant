#!/usr/bin/env bash

helm upgrade --install nfs-subdir-external-provisioner nfs-subdir-external-provisioner \
    --repo https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner \
    --create-namespace \
    --namespace nfs-provisioner \
    --set nfs.server=nfs-server.dimarino.local,nfs.path=/mnt/nfs_share \
    --wait \
    --timeout 10m
