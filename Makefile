include ./include/crd.Makefile
include ./include/gcloud.Makefile
include ./include/var.Makefile
include ./include/images.Makefile

CHART_NAME := plainsight
APP_ID ?= $(CHART_NAME)
VERIFY_WAIT_TIMEOUT = 1800

TRACK ?= 5.3

PLAINSIGHT_TAG ?= 1.0.0

SOURCE_REGISTRY ?= gcr.io/plainsight-public/images
IMAGE_API ?= $(SOURCE_REGISTRY)/api:$(PLAINSIGHT_TAG)
IMAGE_DASHBOARD ?= $(SOURCE_REGISTRY)/dashboard:$(PLAINSIGHT_TAG)
IMAGE_WORKER ?= $(SOURCE_REGISTRY)/worker:$(PLAINSIGHT_TAG)
IMAGE_BILLING ?= $(SOURCE_REGISTRY)/billing:$(PLAINSIGHT_TAG)
IMAGE_MIGRATOR ?= $(SOURCE_REGISTRY)/migrator:$(PLAINSIGHT_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_PLAINSIGHT))

# List of images used in application
ADDITIONAL_IMAGES := ""

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-apache-exporter := $(call get_sha256,$(IMAGE_APACHE_EXPORTER))
image-mysql := $(call get_sha256,$(IMAGE_MYSQL))
image-mysqld-exporter := $(call get_sha256,$(IMAGE_MYSQLD_EXPORTER))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ./include/c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester