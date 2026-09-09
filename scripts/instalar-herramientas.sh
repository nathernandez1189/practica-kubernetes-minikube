#!/usr/bin/env bash
set -euo pipefail

ARCH="$(uname -m)"
case "$ARCH" in
  aarch64|arm64)
    MINIKUBE_ARCH="arm64"
    KUBECTL_ARCH="arm64"
    ;;
  x86_64|amd64)
    MINIKUBE_ARCH="amd64"
    KUBECTL_ARCH="amd64"
    ;;
  *)
    echo "Arquitectura no compatible: $ARCH" >&2
    exit 1
    ;;
esac

if ! command -v minikube >/dev/null 2>&1; then
  curl --fail --location --output /tmp/minikube \
    "https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-${MINIKUBE_ARCH}"
  sudo install -m 0755 /tmp/minikube /usr/local/bin/minikube
fi

if ! command -v kubectl >/dev/null 2>&1; then
  KUBECTL_VERSION="$(curl --fail --location --silent https://dl.k8s.io/release/stable.txt)"
  curl --fail --location --output /tmp/kubectl \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl"
  sudo install -m 0755 /tmp/kubectl /usr/local/bin/kubectl
fi

minikube version
kubectl version --client

