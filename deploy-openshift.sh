#!/bin/bash

set -ex

cd /root/

# Install epel
yum -y install epel-release

# Install storage requirements for iscsi and cluster
yum -y install centos-release-gluster
yum -y install --nogpgcheck -y glusterfs-fuse
yum -y install iscsi-initiator-utils

# Create Origin latest repo, enter correct repository address
cat >/etc/yum.repos.d/origin-latest.repo <<EOF
[my-origin]
name=Origin packages v3.10.0-rc.0
baseurl=https://plain.resources.ovirt.org/repos/origin/3.10/v3.10.0-rc.0/
enabled=1
gpgcheck=0
EOF

# Install OpenShift packages
yum install -y yum-utils \
  ansible \
  wget \
  git \
  net-tools \
  bind-utils \
  iptables-services \
  bridge-utils \
  bash-completion \
  kexec-tools \
  sos \
  psacct \
  docker

echo '{ "insecure-registries" : ["172.30.0.0/16"] }' > /etc/docker/daemon.json

systemctl start docker
systemctl enable docker

# Disable host key checking under ansible.cfg file
sed -i '/host_key_checking/s/^#//g' /etc/ansible/ansible.cfg

openshift_ansible="/root/openshift-ansible"
inventory_file="/root/inventory"
master_ip=`ifconfig eth0 | grep 'inet ' | cut -d: -f2 | awk '{print $2}'`

#git clone https://github.com/openshift/openshift-ansible.git -b v3.10.0-rc.0 $openshift_ansible

# Create ansible inventory file
cat >$inventory_file <<EOF
[OSEv3:children]
masters
nodes

[OSEv3:vars]
ansible_ssh_user=root
ansible_ssh_pass=password
deployment_type=origin
openshift_deployment_type=origin
openshift_clock_enabled=true
openshift_master_identity_providers=[{'name': 'allow_all_auth', 'login': 'true', 'challenge': 'true', 'kind': 'AllowAllPasswordIdentityProvider'}]
openshift_disable_check=memory_availability,disk_availability,docker_storage,package_availability,docker_image_availability
openshift_image_tag=v3.10.0-rc.0
ansible_service_broker_registry_whitelist=['.*-apb$']
openshift_node_kubelet_args={'max-pods': ['80'], 'pods-per-core': ['80']}
openshift_master_admission_plugin_config={"ValidatingAdmissionWebhook":{"configuration":{"kind": "DefaultAdmissionConfig","apiVersion": "v1","disable": false}},"MutatingAdmissionWebhook":{"configuration":{"kind": "DefaultAdmissionConfig","apiVersion": "v1","disable": false}}}

[masters]
localhost ansible_connection=local

[etcd]
localhost ansible_connection=local

[nodes]
# openshift_node_group_name should refer to a dictionary with matching key of name in list openshift_node_groups.
localhost ansible_connection=local openshift_schedulable=true openshift_ip=$master_ip openshift_node_group_name="node-config-master-infra"
EOF

# Install prerequisites
ansible-playbook -i $inventory_file $openshift_ansible/playbooks/prerequisites.yml
touch /etc/sysconfig/origin-node
ansible-playbook -i $inventory_file $openshift_ansible/playbooks/deploy_cluster.yml

# Create OpenShift user
/usr/bin/oc create user admin
/usr/bin/oc create identity allow_all_auth:admin
/usr/bin/oc create useridentitymapping allow_all_auth:admin admin
/usr/bin/oc adm policy add-cluster-role-to-user cluster-admin admin

oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-privileged
oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-controller
oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:kubevirt-infra