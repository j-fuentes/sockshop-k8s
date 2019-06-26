ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

EXT_VARS?="catalogue.dbPassword=very-secure-password"

all: help

help:
	@echo "Use one of the following targets: generate, deploy, delete, diff"
	@echo "Optionally, you can override the default EXT_VARS:"
	@echo ""
	@echo "  make deploy EXT_VARS=\"${EXT_VARS}\""

generate:
	cd $(ROOT_DIR) && kubecfg show --ext-str=$(EXT_VARS) ./kubecfg/sockshop.jsonnet > ./generated/sockshop.yaml

deploy:
	cd $(ROOT_DIR) && kubecfg update --ext-str=$(EXT_VARS) ./kubecfg/sockshop.jsonnet

delete:
	cd $(ROOT_DIR) && kubecfg delete --ext-str=$(EXT_VARS) ./kubecfg/sockshop.jsonnet

diff:
	cd $(ROOT_DIR) && kubecfg diff --ext-str=$(EXT_VARS) ./kubecfg/sockshop.jsonnet
