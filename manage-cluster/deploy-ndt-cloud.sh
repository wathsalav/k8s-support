#!/bin/bash
#
# Deploy the NDT-cloud DaemonSet, and all dependencies.

set -uxe

# TODO: replace with an allocation of per-user credentials.
gcloud compute ssh k8s-platform-master \
    --command "sudo cat /etc/kubernetes/admin.conf" > admin.conf

# Report the current daemonsets.
kubectl --kubeconfig ./admin.conf get daemonsets

# TODO: use file names as parameters to the ndt-cloud container.
# Create the ndt certificates secret.
if [[ ! -f certs/cert.pem || ! -f certs/key.pem ]] ; then
    echo "ERROR: could not find measurementlab certs/cert.pem and certs/key.pem files"
	exit 1
fi
kubectl --kubeconfig ./admin.conf create secret generic ndt-certificates \
    "--from-file=certs" \
    --dry-run -o json | kubectl --kubeconfig ./admin.conf apply -f -

# Create the ndt-cloud daemonset.
kubectl --kubeconfig ./admin.conf apply \
    -f ../k8s/mlab-platform/daemonsets/ndt-cloud.yml

# Report the new daemonsets.
kubectl --kubeconfig ./admin.conf get daemonsets