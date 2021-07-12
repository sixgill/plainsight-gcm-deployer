TAG ?= latest

# Convenience makefiles.
include include/gcloud.Makefile
include include/var.Makefile

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/example/sense/deployer:$(TAG)
NAME ?= sense-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
  "imagesense.image": "$(REGISTRY)/example/sense:$(TAG)" \
}
TESTER_IMAGE ?= $(REGISTRY)/example/sense/tester:$(TAG)
APP_TEST_PARAMETERS ?= { \
  "tester.image": "$(TESTER_IMAGE)" \
}

# app.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app.Makefile


# Extend the target as defined in app.Makefile to
# include real dependencies.
app/build:: .build/sense/deployer \
            .build/sense/sense \
            .build/sense/tester


.build/sense: | .build
	mkdir -p "$@"

.build/sense/deployer: apptest/deployer/* \
                       apptest/deployer/sense/* \
                       apptest/deployer/sense/templates/* \
                       deployer/* \
                       sense/* \
                       sense/templates/* \
                       schema.yaml \
                       .build/var/APP_DEPLOYER_IMAGE \
                       .build/var/MARKETPLACE_TOOLS_TAG \
                       .build/var/REGISTRY \
                       .build/var/TAG \
                       | .build/sense
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/sense/tester: .build/var/TESTER_IMAGE \
                     | .build/sense
	$(call print_target, $@)
	docker pull cosmintitei/bash-curl
	docker tag cosmintitei/bash-curl "$(TESTER_IMAGE)"
	docker push "$(TESTER_IMAGE)"
	@touch "$@"


# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/sense/sense: .build/var/REGISTRY \
                    .build/var/TAG \
                    | .build/sense
	$(call print_target, $@)
	docker pull launcher.gcr.io/google/sense1
	docker tag launcher.gcr.io/google/sense1 "$(REGISTRY)/example/sense:$(TAG)"
	docker push "$(REGISTRY)/example/sense:$(TAG)"
	@touch "$@"
