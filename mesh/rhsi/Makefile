#
# Makefile : Online Boutique -B option
#
#
####################################################
# Used by install-ob.sh when invookd with -B option
####################################################

# Check all necessary environment variables
-include ./env.var.app.cmd.mk
-include ./env.var.app.image.mk

# Chznge this as needed. Update in hzn.json as well
IMAGE_TAG=1.0.0

# Load customized ENV vars for build, push and k8s deployment.
# patch-need-* Used by install-ob.sh to determone determoens if patch is needed.
# - Have an entry in MAKECMDGOALS
# - Have a target by the same name
# patch-file-* creates a file if patch is needed
# - Creates patch file by using enbsubst for the target hzn.jzon 

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),patch-need-adservice patch-file-adservice))
-include hzn.json.adservice.mk
endif

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),patch-need-cartservice patch-file-cartservice))
-include hzn.json.cartservice.mk
endif

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),patch-need-checkoutservice patch-file-checkoutservice))
-include hzn.json.checkoutservice.mk
endif

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),patch-need-currencyservice patch-file-currencyservice))
-include hzn.json.currencyservice.mk
endif

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),patch-need-emailservice patch-file-emailservice))
-include hzn.json.emailservice.mk
endif

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),patch-need-frontend patch-file-frontend))
-include hzn.json.frontend.mk
endif

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),patch-need-loadgenerator patch-file-loadgenerator))
-include hzn.json.loadgenerator.mk
endif

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),patch-need-paymentservice patch-file-paymentservice))
-include hzn.json.paymentservice.mk
endif

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),patch-need-productcatalogservice patch-file-productcatalogservice))
-include hzn.json.productcatalogservice.mk
endif

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),patch-need-recommendationservice patch-file-recommendationservice))
-include hzn.json.recommendationservice.mk
endif

ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),patch-need-shippingservice patch-file-shippingservice))
-include hzn.json.shippingservice.mk
endif

# Create customized ENV vars for build, push and k8s deployment
hzn.json.adservice.mk: src/adservice/hzn/hzn.json
	@ hzn util configconv -f $< > $@

hzn.json.cartservice.mk: src/cartservice/hzn/hzn.json
	@ hzn util configconv -f $< > $@

hzn.json.checkoutservice.mk: src/checkoutservice/hzn/hzn.json
	@ hzn util configconv -f $< > $@

hzn.json.currencyservice.mk: src/currencyservice/hzn/hzn.json
	@ hzn util configconv -f $< > $@

hzn.json.flightservice.mk: src/flightservice/hzn/hzn.json
	@ hzn util configconv -f $< > $@

hzn.json.emailservice.mk: src/emailservice/hzn/hzn.json
	@ hzn util configconv -f $< > $@

hzn.json.frontend.mk: src/frontend/hzn/hzn.json
	@ hzn util configconv -f $< > $@

hzn.json.loadgenerator.mk: src/loadgenerator/hzn/hzn.json
	@ hzn util configconv -f $< > $@

hzn.json.paymentservice.mk: src/paymentservice/hzn/hzn.json
	@ hzn util configconv -f $< > $@

hzn.json.productcatalogservice.mk: src/productcatalogservice/hzn/hzn.json
	@ hzn util configconv -f $< > $@

hzn.json.recommendationservice.mk: src/recommendationservice/hzn/hzn.json
	@ hzn util configconv -f $< > $@

hzn.json.shippingservice.mk: src/shippingservice/hzn/hzn.json
	@ hzn util configconv -f $< > $@

# Targets to automate service specific patch files
patch-need-adservice:
	@echo ""
patch-file-adservice: check_var_namespace
	@echo "\033[1;30mCreating deploy patch for $(DOCKER_IMAGE):$(SERVICE_VERSION) \033[0m"
	envsubst < ./deploy-patch.yaml.tmpl > ./patch/deploy-${K_DEPLOY_NAME}-patch.yaml

patch-need-cartservice: 
	@echo ""
patch-file-cartservice: check_var_namespace
	@echo "\033[1;30mCreating deploy patch $(DOCKER_IMAGE):$(SERVICE_VERSION) \033[0m"
	envsubst < ./deploy-patch.yaml.tmpl > ./patch/deploy-${K_DEPLOY_NAME}-patch.yaml

patch-need-checkoutservice:
	@echo ""
patch-file-checkoutservice: check_var_namespace
	@echo "\033[1;30mCreating deploy patch $(DOCKER_IMAGE):$(SERVICE_VERSION) \033[0m"
	envsubst < ./deploy-patch.yaml.tmpl > ./patch/deploy-${K_DEPLOY_NAME}-patch.yaml

patch-need-currencyservice:
	@echo ""
patch-file-currencyservice: check_var_namespace
	@echo "\033[1;30mCreating deploy patch $(DOCKER_IMAGE):$(SERVICE_VERSION) \033[0m"
	envsubst < ./deploy-patch.yaml.tmpl > ./patch/deploy-${K_DEPLOY_NAME}-patch.yaml

patch-need-emailservice:
	@echo ""
patch-file-emailservice: check_var_namespace
	@echo "\033[1;30mCreating deploy patch $(DOCKER_IMAGE):$(SERVICE_VERSION) \033[0m"
	envsubst < ./deploy-patch.yaml.tmpl > ./patch/deploy-${K_DEPLOY_NAME}-patch.yaml

patch-need-frontend:
	@echo ""
patch-file-frontend: check_var_namespace
	@echo "\033[1;30mCreating deploy patch $(DOCKER_IMAGE):$(SERVICE_VERSION) \033[0m"
	envsubst < ./deploy-patch.yaml.tmpl > ./patch/deploy-${K_DEPLOY_NAME}-patch.yaml

patch-need-loadgenerator:
	@echo ""
patch-file-loadgenerator: check_var_namespace
	@echo "\033[1;30mCreating deploy patch $(DOCKER_IMAGE):$(SERVICE_VERSION) \033[0m"
	envsubst < ./deploy-patch.yaml.tmpl > ./patch/deploy-${K_DEPLOY_NAME}-patch.yaml

patch-need-paymentservice:
	@echo ""
patch-file-paymentservice: check_var_namespace
	@echo "\033[1;30mCreating deploy patch $(DOCKER_IMAGE):$(SERVICE_VERSION) \033[0m"
	envsubst < ./deploy-patch.yaml.tmpl > ./patch/deploy-${K_DEPLOY_NAME}-patch.yaml

patch-need-productcatalogservice:
	@echo ""
patch-file-productcatalogservice: check_var_namespace
	@echo "\033[1;30mCreating deploy patch $(DOCKER_IMAGE):$(SERVICE_VERSION) \033[0m"
	envsubst < ./deploy-patch.yaml.tmpl > ./patch/deploy-${K_DEPLOY_NAME}-patch.yaml

patch-need-recommendationservice:
	@echo ""
patch-file-recommendationservice: check_var_namespace
	@echo "\033[1;30mCreating deploy patch $(DOCKER_IMAGE):$(SERVICE_VERSION) \033[0m"
	envsubst < ./deploy-patch.yaml.tmpl > ./patch/deploy-${K_DEPLOY_NAME}-patch.yaml

patch-need-shippingservice:
	@echo ""
patch-file-shippingservice: check_var_namespace
	@echo "\033[1;30mCreating deploy patch $(DOCKER_IMAGE):$(SERVICE_VERSION) \033[0m"
	envsubst < ./deploy-patch.yaml.tmpl > ./patch/deploy-${K_DEPLOY_NAME}-patch.yaml

check_var_namespace:
	$(call cmd_var_check,NAMESPACE,as make <target> NAMESPACE=<namespace>)
	@echo ""
	@echo "NAMESPACE: ${NAMESPACE}"

#build and push images. Bulid takes long time first time
build-push: 
	@echo ""
	@echo "\033[1;30mLogin into container registry ${CR_HOST} \033[0m"
	@echo "${CR_APP_API_KEY_RW_PUSH}" | docker login ${CR_HOST} -u ${CR_HOST_USERNAME} --password-stdin
	@echo ""
	@echo "\033[1;30mBuilding images \033[0m"
	@cd ../.. ; \
	skaffold build --default-repo ${CR_HOST}/${CR_HOST_NAMESPACE} --platform=linux/amd64 --tag=${IMAGE_TAG}

