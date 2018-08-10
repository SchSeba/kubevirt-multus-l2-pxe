FROM centos:latest

ADD . /usr/src/cni-plugins/

WORKDIR /

LABEL io.k8s.display-name="CNI Plugins" \
      io.k8s.description="This is a component of OpenShift Container Platform and provides all CNI plugins." \
      io.openshift.tags="openshift" \
      maintainer="Sebastian Scheinkman <sscheink@redhat.com>"

ADD entrypoint.sh /

# does it require a root user?
# USER 1001

ENTRYPOINT /entrypoint.sh
