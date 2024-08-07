.PHONY: all

all: azure-kamaji azure-kamaji-tenant conformance azure-destroy 

azure-aks-create:
	./azure/scripts/create-admin-cluster.bash

kamaji-setup:
	./kamaji/scripts/install-kamaji.bash

tenant-control-plane: 
	./kamaji/scripts/create-control-plane.bash

azure-tenant-machines:
	./azure/scripts/create-cloudinit.bash
	./azure/scripts/create-vm.bash

tenant-workers:
	./kamaji/scripts/export-kubeconfig.bash
	./kamaji/scripts/export-join-command.bash
	./azure/scripts/join-vm.bash
	./kamaji/scripts/install-cni.bash

azure-kamaji: azure-aks-create kamaji-setup

azure-kamaji-tenant: tenant-control-plane azure-tenant-machines tenant-workers

conformance:
	./sonobuoy/scripts/cncf-conformance.bash

azure-destroy:
	./azure/scripts/destroy-all.bash

