FROM centos:centos7

# Add everything
ADD l2-bridge /usr/src/l2-bridge-cni/l2-bridge

WORKDIR /

LABEL io.k8s.display-name="L2 Bridge CNI" \
      io.k8s.description="This is a component of OpenShift Container Platform and provides a l2 bridge CNI plugin." \
      io.openshift.tags="openshift" \
      maintainer="Sebastian Scheinkman <sscheink@redhat.com>"

ADD entrypoint.sh /

# does it require a root user?
# USER 1001

ENTRYPOINT /entrypoint.sh