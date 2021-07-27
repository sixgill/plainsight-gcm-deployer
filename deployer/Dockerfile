FROM marketplace.gcr.io/google/debian10 AS build

RUN mkdir /third-party
ADD docs/* /third-party

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD Plainsight /tmp/chart
RUN cd /tmp \
    && tar -czvf /tmp/Plainsight.tar.gz chart
ADD apptest/deployer/Plainsight /tmp/test/chart
RUN cd /tmp/test \
    && tar -czvf /tmp/test/Plainsight.tar.gz chart/

ADD schema.yaml /tmp/schema.yaml

# Provide registry prefix and tag for default values for images.
ARG REGISTRY
ARG TAG
RUN cat /tmp/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/schema.yaml.new \
    && mv /tmp/schema.yaml.new /tmp/schema.yaml

#ENTRYPOINT [ "/bin/bash" ] # This is for the :debug image

FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm
COPY --from=build /tmp/Plainsight.tar.gz /data/chart/
COPY --from=build /tmp/test/Plainsight.tar.gz /data-test/chart/
COPY apptest/deployer/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/
