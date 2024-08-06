ifeq (, $(shell which yq))
	$(error "No yq in $(PATH), please install yq")
endif

ifeq (, $(shell which k2tf))
	$(error "No k2tf in $(PATH), please install k2tf")
endif

ifeq (, $(shell which terraform))
	$(error "No terraform in $(PATH), please install terraform")
endif


all: clean manifests convert clean

manifests:
	cd helm ; terraform init && terraform apply -auto-approve

roles:
	cat helm/*role* | k2tf -xo roles.tf

daemonsets:
	cat helm/*daemonset* | k2tf -xo daemonset.tf

deployments:
	cat helm/*deployment* | k2tf -xo deployment.tf

secrets:
	cat helm/*secret* | k2tf -xo secret.tf

serviceaccounts:
	cat helm/*serviceaccount* | k2tf -xo service-accounts.tf

configmaps:
	cat helm/*configmap* | k2tf -xo config.tf

services:
	cat helm/*service* | k2tf -xo service.tf

cleanyaml:
	cd helm ; rm .yml *.yml || true

cleantf:
	cd helm ; rm -rf .terraform* || true

clean: cleanyaml cleantf

.convert:
	cd helm ; yq -s '(.kind | downcase) + $$index' manifests.yaml

convert: .convert roles daemonsets deployments secrets serviceaccounts configmaps 

diff_% :
	vimdiff $*.tf helm/$*.tf
