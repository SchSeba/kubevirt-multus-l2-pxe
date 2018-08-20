# kubevirt-multus-l2-pxe

## Requirements
* openshift/kubernetes cluster running
* admin privileges on the cluster
* oc/kubectl command installed

*note:* You can use the `deploy-openshift.sh` script to create a test cluster localy. Copy the script to /root/ and run it.

## Create the bridge

The L2-bridge plugin need to have a bridge configured on every node in the cluster. Create the configuration for the bridge and the physical interface.

Bridge Configuration:

```
/etc/sysconfig/network-scripts/ifcfg-<bridge-mame>

TYPE=Bridge
BOOTPROTO=none
NAME=<bridge-mame>
DEVICE=<bridge-mame>
NM_CONTROLLED=no
ONBOOT=yes
```

Change the physical interface configuration:

```
/etc/sysconfig/network-scripts/ifcfg-<physical-interface>
TYPE=Ethernet
BOOTPROTO=none
NM_CONTROLLED=no
BRIDGE=<bridge-name>
NAME=<physical-interface>
DEVICE=<physical-interface>
ONBOOT=yes
```

## Allow traffic from the bridge interface

```
iptables -I INPUT 1 -i <bridge-name> -j ACCEPT
iptables -I FORWARD 1 -i <bridge-name> -j ACCEPT
```

## Deploy multus with L2-bridge plugin

```
oc/kubectl apply -f deployment.yaml
```

## Create L2-bridge NetworkAttachmentDefinition yaml

```
cat <<EOF | kubectl create -f -
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: l2-bridge-conf
spec: 
  config: '{
      "name": "mynet",
      "cniVersion": "0.3.0",
      "type": "l2-bridge",
      "bridge": "<bridge-name>",
      "ipam": {}
    }'
EOF
```