# docker.mk

# provides common build/tag/deploy functionality for Docker images
#
# required variables :
#	 IMAGE_NAME : name of your docker image
#
# optional variables:
#    DOCKER_FILE : location of Dockerfile, defaults to ./Dockerfile
#    DISABLE_DOCKER_PULL : docker builds will pull parent images by default, set to `true` to disable
#    DEFAULT_TAG : defaults to 'latest'
#    DOCKER_REGISTRY : Docker registry to push to, 
#    ENABLE_AQUA_SCAN : defaults to 'false'. If 'true' will perform aquasec scan of build image. False bypasses scanning.
#    AQUASEC_HOST : Aquasec console host to send scan result to.
#    MAKE_COMMON : directory containing shared makefile for local testing
#    DOCKER_BUILD_FLAGS : List of docker build flags to use, defaults to "--no-cahce=true --rm"
#    BUILD_ARGS : List of arg value pairs separated by spaces that are passed to docker build 
#    			 as --build-arg options. Example: BUILD_ARGS = ARG1=FOO ARG2=BAR
#    

DEFAULT_TAG = latest


ifneq ($(MAKECMDGOALS),clean)
	ifndef IMAGE_NAME
		$(error IMAGE_NAME variable not specified.)
	endif
endif

DOCKER_FILE ?= ./Dockerfile
DOCKER_REGISTRY ?= anilrgpv.jfrog.io
.DEFAULT_GOAL := build

DOCKER_BUILD_FLAGS ?= --no-cahce=true --rm
ifneq ($(DISABLE_DOCKER_PULL),true)
	DOCKER_BUILD_FLAGS += --pull
endif

# for scanning all builds - default to false
ENABLE_AQUA_SCAN ?=false

# all direct goal call to security-scan-aqua
ifeq ($(filter security-scan-aqua, $(MAKECMDGOALS)), security-scan-aqua)
	ENABLE_AQUA_SCAN = true
endif

# feq ($(ENABLE_AQUA_SCAN),true)
# 	AQUASEC_SCAN_FLAG=--no-verify
# 	AQUASEC_HOST ?= https://aquasec-dev.internal.shutterfly.com
# 	AQUACRED = $(shell queryThycoticSecret.pl --tusername $(thycotic_aquasec_username) --tpassword '$(thycotic_aquasec_password)' --secret '\Shared\' --template 'API Access' --field 'Username:API Key')
# 	AQUASEC_USER= $(shell echo ${AQUACRED} | cut -f 1 -d " " | cut -f 2 -d " ")
# 	AQUASEC_PSWD= $(shell echo ${AQUACRED} | cut -f 3 -d " " | cut -f 2 -d " ")
# endif


build: prepare $(DOCKER_FILE)
		@echo "*** building $(DOCKER_REGISTRY)/$(IMAGE_NAME) ***"
		docker build $(addprefix --build-arg , $(BUILD_ARGS)) -t $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(DEFAULT_TAG) .
		@$(call write-result,image_id=$(DOCKER_REGISTRY)/$(IMAGE_NAME))
		@$(call write-result,image_name=$(IMAGE_NAME))


.PHONY: tag
tag: build
		@echo "*** tagging $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(DEFAULT_TAG) as $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(MAKE_BUILD_ID) ***"
		docker tag $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(DEFAULT_TAG) $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(MAKE_BUILD_ID)
		@$(call write-result,image_tag=$(MAKE_BUILD_ID))
		@$(call write-result,$(subst .,_,$(subst -,_,$(subst /,_,$(IMAGE_NAME)))_tag=$(MAKE_BUILD_ID)))


.PHONY: deploy
deploy: tag
		@echo "*** deploying $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(MAKE_BUILD_ID) ***"
		docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(MAKE_BUILD_ID)
		docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(DEFAULT_TAG)
