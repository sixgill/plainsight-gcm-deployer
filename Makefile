TAG ?= latest

# Convenience makefiles.
include include/gcloud.Makefile
include include/var.Makefile

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/example/Plainsight/deployer:$(TAG)
NAME ?= Plainsight-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
  "imagePlainsight.image": "$(REGISTRY)/example/Plainsight:$(TAG)" \
}
TESTER_IMAGE ?= $(REGISTRY)/example/Plainsight/tester:$(TAG)
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
app/build:: .build/Plainsight/deployer \
            .build/Plainsight/Plainsight \
            .build/Plainsight/tester


.build/Plainsight: | .build
	mkdir -p "$@"

.build/Plainsight/deployer: apptest/deployer/* \
                       apptest/deployer/Plainsight/* \
                       apptest/deployer/Plainsight/templates/* \
                       deployer/* \
                       Plainsight/* \
                       Plainsight/templates/* \
                       schema.yaml \
                       .build/var/APP_DEPLOYER_IMAGE \
                       .build/var/MARKETPLACE_TOOLS_TAG \
                       .build/var/REGISTRY \
                       .build/var/TAG \
                       | .build/Plainsight
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/Plainsight/tester: .build/var/TESTER_IMAGE \
                     | .build/Plainsight
	$(call print_target, $@)
	docker pull cosmintitei/bash-curl
	docker tag cosmintitei/bash-curl "$(TESTER_IMAGE)"
	docker push "$(TESTER_IMAGE)"
	@touch "$@"


# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/Plainsight/Plainsight: .build/var/REGISTRY \
                    .build/var/TAG \
                    | .build/Plainsight
	$(call print_target, $@)
	docker pull launcher.gcr.io/google/Plainsight1
	docker tag launcher.gcr.io/google/Plainsight1 "$(REGISTRY)/example/Plainsight:$(TAG)"
	docker push "$(REGISTRY)/example/Plainsight:$(TAG)"
	@touch "$@"
