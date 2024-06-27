FROM mcr.microsoft.com/azure-cli:latest

LABEL repo="https://github.com/clastix/kamaji-cncf-conformance"
LABEL image="docker.io/clastix/kamaji-cncf-conformance:latest"

ARG ARCH=amd64
ARG KUBE_URL=https://storage.googleapis.com
ARG KUBE_VERSION=v1.27.3

ARG HELM_VER=v3.9.2
ARG HELM_URL=https://get.helm.sh

ARG SONOBUOY_VERSION=v0.57.1
ARG SONOBUOY_URL=https://github.com/vmware-tanzu/sonobuoy

ENV KAMAJI_REGION=westeurope
ENV KAMAJI_VERSION=v0.3.3
ENV TENANT_VERSION=v1.27.3

RUN apk --no-cache add curl
RUN curl -LO ${KUBE_URL}/kubernetes-release/release/${KUBE_VERSION}/bin/linux/${ARCH}/kubeadm && \
mv kubeadm /usr/local/bin/kubeadm && \
chmod +x /usr/local/bin/kubeadm

RUN curl -LO ${KUBE_URL}/kubernetes-release/release/${KUBE_VERSION}/bin/linux/${ARCH}/kubectl && \
mv kubectl /usr/local/bin/kubectl && \
chmod +x /usr/local/bin/kubectl

RUN curl -LO ${HELM_URL}/helm-${HELM_VER}-linux-${ARCH}.tar.gz && \
tar xzvf helm-${HELM_VER}-linux-${ARCH}.tar.gz -C /tmp && \
mv /tmp/linux-${ARCH}/helm /usr/local/bin/helm && \
rm -f helm-${HELM_VER}-linux-${ARCH}.tar.gz

RUN curl -LO ${SONOBUOY_URL}/releases/download/${SONOBUOY_VERSION}/sonobuoy_${SONOBUOY_VERSION:1}_linux_${ARCH}.tar.gz && \
tar xzvf sonobuoy_${SONOBUOY_VERSION:1}_linux_${ARCH}.tar.gz -C /tmp && \
mv /tmp/sonobuoy /usr/local/bin/sonobuoy && \
rm -f sonobuoy_${SONOBUOY_VERSION:1}_linux_${ARCH}.tar.gz

