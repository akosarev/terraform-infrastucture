SHELL := /bin/bash
export PATH := var:$(PATH):$(VENV_DIR)/bin
default: help

help:
	@echo 'Usage: make [target] ...'
	@echo
	@echo 'Targets:'
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep  \
	| sed -e 's/^\(.*\):[^#]*#\(.*\)/\1 \2/' | tr '#' "\t"

##

init: #### Initialization of terraform
	terraform init

validate: #### Validate
	@make init
	terraform validate

plan: #### Create a plan for your infra
	@make validate
	terraform plan

apply: #### Deploy your infra
	@make validate
	terraform apply --auto-approve

destroy: #### Destroy everything
	@make validate
	terraform destroy --auto-approve

