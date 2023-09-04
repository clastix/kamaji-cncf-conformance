#!/bin/bash

# export KUBECONFIG=/home/$USER/.kube/config

function get_tenants() {
    kubectl get tenantcontrolplanes
}

function create_tenant_controlplane() {
    NAME=$1
    DOMAIN=$2
    VERSION=$3
    PORT=$4
    PROXY_PORT=$5
    tcp_manifest $NAME $DOMAIN $VERSION $PORT $PROXY_PORT
    kubectl apply -f /tmp/$NAME.yaml
}

function create_kubeconfig() {
    NAME=$1
    DOMAIN=$2
    kubectl wait tcp/$NAME --for jsonpath='{.status.kubernetesResources.version.status}=Ready' --timeout=120s
    kubectl get secrets $NAME-admin-kubeconfig -o json | jq -r '.data["admin.conf"]' | base64 -d > /tmp/$NAME.kubeconfig
    kubectl --kubeconfig=/tmp/$NAME.kubeconfig config set-cluster $NAME --server https://$NAME.$DOMAIN
}

function create_join_command() {
  NAME=$1
  ENDPOINT=$2
  echo -n "sudo kubeadm join $ENDPOINT "$(kubeadm --kubeconfig=/tmp/$NAME.kubeconfig token create --print-join-command | cut -d" " -f4-) > /tmp/$NAME-join.cmd
}

function get_internal_lb_address() {
  NAME=$1
  echo -n $(kubectl get svc ${NAME} -o json | jq -r '.status.loadBalancer.ingress[0].ip')
}

function tcp_manifest() {
    NAME=$1
    DOMAIN=$2
    VERSION=$3
    PORT=$4
    PROXY_PORT=$5
    cat > /tmp/$NAME.yaml << EOF
apiVersion: kamaji.clastix.io/v1alpha1
kind: TenantControlPlane
metadata:
  name: ${NAME}
spec:
  controlPlane:
    deployment:
      replicas: 3
      additionalMetadata:
        labels:
          tenant.clastix.io: ${NAME}
      extraArgs:
        apiServer: []
        controllerManager: []
        scheduler: []
      resources:
        apiServer:
          requests:
            cpu: 250m
            memory: 512Mi
          limits: {}
        controllerManager:
          requests:
            cpu: 125m
            memory: 256Mi
          limits: {}
        scheduler:
          requests:
            cpu: 125m
            memory: 256Mi
          limits: {} 
    service:
      additionalMetadata:
        labels:
          tenant.clastix.io: ${NAME}
        annotations:
          service.beta.kubernetes.io/azure-load-balancer-internal: "true"
      serviceType: LoadBalancer
  kubernetes:
    version: ${VERSION}
    kubelet:
      cgroupfs: systemd
    admissionControllers:
      - ResourceQuota
      - LimitRanger
  networkProfile:
    port: ${PORT}
    certSANs:
    - ${NAME}.${DOMAIN}
    serviceCidr: 10.96.0.0/16
    podCidr: 10.36.0.0/16
    dnsServiceIPs:
    - 10.96.0.10
  addons:
    coreDNS: {}
    kubeProxy: {}
    konnectivity:
      server:
        port: 8132
        resources: {}
      agent: {}
---
apiVersion: v1
kind: Service
metadata:
  name: ${NAME}-public
  annotations:
    service.beta.kubernetes.io/azure-dns-label-name: ${NAME}
spec:
  ports:
  - port: 443
    protocol: TCP
    targetPort: ${PORT}
  selector:
    kamaji.clastix.io/name: ${NAME}
  type: LoadBalancer
EOF

}
