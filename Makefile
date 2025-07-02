BUILD_DIR=build
APPS=front-end newsfeed quotes
STATIC_BASE=front-end/api/static
STATIC_PATHS=css
STATIC_ARCHIVE=$(BUILD_DIR)/static.tgz
DOCKER_TARGETS=$(addsuffix .docker, $(APPS))
DOCKER_PUSH_TARGETS=$(addsuffix .push, $(APPS))
_DOCKER_PUSH_TARGETS=$(addprefix _, $(DOCKER_PUSH_TARGETS))
ACR_URL_FILE=infra/acr-url.txt
SSH_KEY=infra/id_rsa
PREFIX=$$(cat interview_id.txt)
RESOURCE_GROUP_NAME=news$(PREFIX)_rg_joi_interview
STORAGE_ACCOUNT_NAME=news$(PREFIX)sajoiinterview
CONTAINER_NAME=news$(PREFIX)terraformcontainerjoiinterview

az_login:
	az login

az_account:	
	az group create --name $(RESOURCE_GROUP_NAME) --location eastus	
	az storage account create --resource-group $(RESOURCE_GROUP_NAME) --name $(STORAGE_ACCOUNT_NAME) --sku Standard_LRS --encryption-services blob	
	az storage container create --name $(CONTAINER_NAME) --account-name $(STORAGE_ACCOUNT_NAME)

delete_az_account:
	az group delete --resource-group $(RESOURCE_GROUP_NAME) -y

static: $(STATIC_ARCHIVE)

test: $(addprefix _, $(addsuffix .test, $(APPS)))

clean:
	rm -rf $(BUILD_DIR)

$(STATIC_ARCHIVE): | $(BUILD_DIR)
	tar -c -C $(STATIC_BASE) -z -f $(STATIC_ARCHIVE) $(STATIC_PATHS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

%.docker:
	$(eval IMAGE_NAME = $(subst -,_,$*))	
	cd $* && docker buildx build --platform linux/amd64 --load -t $(IMAGE_NAME) .	

_%.push:
	$(eval IMAGE_NAME = $(subst -,_,$*))
	$(eval REPO_URL := $(shell cat ${ACR_URL_FILE}))	
	docker tag $(IMAGE_NAME) news$(PREFIX)$(subst _,,$(IMAGE_NAME))$(REPO_URL)/news$(PREFIX)$(subst _,,$(IMAGE_NAME))
	az acr login --name news$(PREFIX)$(subst _,,$(IMAGE_NAME)) 
	docker push news$(PREFIX)$(subst _,,$(IMAGE_NAME))$(REPO_URL)/news$(PREFIX)$(subst _,,$(IMAGE_NAME))

%.push:
	$(eval IMAGE_NAME = $(subst -,_,$*))
	$(eval REPO_URL := $(shell cat ${ACR_URL_FILE}))	
	docker tag $(IMAGE_NAME) news$(PREFIX)$(subst _,,$(IMAGE_NAME))$(REPO_URL)/news$(PREFIX)$(subst _,,$(IMAGE_NAME))
	az acr login --name news$(PREFIX)$(subst _,,$(IMAGE_NAME)) 
	docker push news$(PREFIX)$(subst _,,$(IMAGE_NAME))$(REPO_URL)/news$(PREFIX)$(subst _,,$(IMAGE_NAME))

docker: $(DOCKER_TARGETS)	

push: $(DOCKER_PUSH_TARGETS)

$(SSH_KEY):
	ssh-keygen -q -N "" -t rsa -b 4096 -f $(SSH_KEY)
	chmod -c 0600 $(SSH_KEY)

ssh_key: $(SSH_KEY)

deploy-news:
	@if [ -z "$$TF_VAR_newsfeed_service_token" ]; then \
		echo "Error: TF_VAR_newsfeed_service_token is not set"; \
		echo "Please set it with: export export TF_VAR_newsfeed_service_token=<your-token>"; \
		exit 1; \
	fi
	@echo "Token is set, proceeding with deployment"

%.infra: ssh_key
	if [ "$*" = "news" ]; then \
		echo "Applying Terraform for 'news' with newsfeed_service_token environment variable"; \
		if [ -z "$$TF_VAR_newsfeed_service_token" ]; then \
			echo "Error: TF_VAR_newsfeed_service_token must be set before running 'make news.infra'."; \
			echo "Please set it with: export TF_VAR_newsfeed_service_token=<your-token>"; \
			exit 1; \
		fi; \
		cd infra/$* && rm -rf .terraform && terraform init && terraform apply -auto-approve; \
	else \
		echo "Applying Terraform for '$*' without additional environment variables"; \
		cd infra/$* && rm -rf .terraform && terraform init && terraform apply -auto-approve; \
	fi
# Note: Set the NEWSFEED_SERVICE_TOKEN environment variable before running 'make news.infra' if needed:
# export NEWSFEED_SERVICE_TOKEN=<your-token>; make news.infra

%.deinfra: ssh_key
	cd infra/$* && terraform init && terraform destroy -auto-approve

deploy_site:
	cd build &&\
	mkdir -p static &&\
	cd static &&\
	tar xf ../static.tgz &&\
	rm ../static.tgz &&\
	cd ../../
	az storage blob upload-batch --destination news$(PREFIX)psc --account-name news$(PREFIX)psa --source build --overwrite 
deploy_interview:
#	$(MAKE) az_login
	$(MAKE) az_account
	$(MAKE) clean	
	$(MAKE) backend-support.infra
	$(MAKE) base.infra
	$(MAKE) docker
	$(MAKE) push
	$(MAKE) static
	$(MAKE) deploy_site
	$(MAKE) deploy-news	
	$(MAKE) news.infra	

destroy_interview:
	$(MAKE) news.deinfra
	$(MAKE) base.deinfra
	$(MAKE) backend-support.deinfra
	$(MAKE) delete_az_account
