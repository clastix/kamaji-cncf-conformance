# Run CNCF Conformance test suite on Kamaji Tenant Cluster

We assume you have installed on your workstation:

- [make](https://www.gnu.org/software/make/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [kubeadm](https://kubernetes.io/docs/tasks/tools/#kubeadm)
- [helm](https://helm.sh/docs/intro/install/)
- [jq](https://stedolan.github.io/jq/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [sonobuoy](https://github.com/vmware-tanzu/sonobuoy)

To run this conformance test suite, you need for a valid MS Azure subscription:

```bash
az account set --subscription "MySubscription"
az login
```

## To reproduce:

Clone the repo:

```bash
git clone https://github.com/clastix/kamaji-cncf-conformance
cd kamaji-cncf-conformance
```

and set your environment:

```bash
# Set Azure Region
export KAMAJI_REGION=westeurope

# Set Kubernetes version of Tenant Cluster
export TENANT_VERSION=v1.25.0
```

### Provision Kamaji Admin Cluster

You need to provision an AKS cluster and turn it into a Kamaji Admin Cluster. To do so, please run the following command:

```bash
make azure-kamaji
```

### Provision Kamaji Tenant Cluster

To recreate these results, create a Kamaji Tenant Cluster:

```bash
make azure-kamaji-tenant
```

### Run conformance tests

Tests are run according to the [official instructions](https://github.com/cncf/k8s-conformance/blob/master/instructions.md):

```bash
make conformance
```

Results are left under the `/tmp` folder of your workstation.

### Clean-up

To delete the entire infrastructure, please run the following command:

```bash
make azure-destroy
```

## All in one
Run the conformance test with a single command

```bash
make
```
