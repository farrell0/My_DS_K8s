#!/bin/bash


#  Originally from,
#     https://github.com/datastax/cass-operator
#
#  Now,
#     https://github.com/k8ssandra/k8ssandra
#


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'helm' and 'kubectl' to install K8ssandra with StarGate ..."
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


echo "Delete/create our preferred namespace: ${MY_K8S_NS}"
echo ""
kubectl delete namespace ${MY_K8S_NS}
kubectl create namespace ${MY_K8S_NS}
echo ""

echo "Add Helm repositories .."
echo ""
helm repo add k8ssandra https://helm.k8ssandra.io/
helm repo add traefik https://helm.traefik.io/traefik
echo ""
echo "Update Helm metadata .."
helm repo update
echo ""

echo "Install K8ssandra proper .. (many pods, this takes a bit) ..."
echo ""


#
#  I was using this
#
#  helm install k8ssandra k8ssandra/k8ssandra -n ${MY_K8S_NS} \
#     --set stargate.enabled=true \
#     --set cassandra.version=4.0.0

#
#  Now using this
#
# helm install k8ssandra k8ssandra/k8ssandra -n ${MY_K8S_NS} \
#    --set stargate.enabled=true \
#    --set cassandra.version=4.0.2 \
#    --set kube-prometheus-stack.enabled=false \
#    --set reaper-operator.enabled=false \
#    --set medusa.enabled=false \
#    --set cass-operator.enabled=true \
#    --set cass-operator.clusterScoped=true 

helm install k8ssandra k8ssandra/k8ssandra -n ${MY_K8S_NS} \
   --set stargate.enabled=true \
   --set cassandra.version=4.0.0 \
   --set kube-prometheus-stack.enabled=false \
   --set reaper-operator.enabled=false \
   --set medusa.enabled=false \
   --set cass-operator.enabled=true \
   --set cass-operator.clusterScoped=true 

# helm install k8ssandra k8ssandra/k8ssandra -n ${MY_K8S_NS} \
#    --set stargate.enabled=true \
#    --set cassandra.version=4.0.0 \
#    --set kube-prometheus-stack.enabled=true \
#    --set reaper-operator.enabled=true \
#    --set medusa.enabled=true \
#    --set cass-operator.enabled=true \
#    --set cass-operator.clusterScoped=true 

#  --set cassandra.datacenters[0].size=0
#
#  this failed
#
#     Error: YAML parse error on k8ssandra/templates/reaper/reaper.yaml: error converting YAML to JSON: yaml: line 23: did not find expected key


echo ""
echo ""
echo "Next steps:"
echo ""
echo "   watch kubectl -n ${MY_K8S_NS} get pods"
echo "   kubectl -n ${MY_K8S_NS} get pods"
echo ""
echo "   File 80, which runs bash(C) into a K8s C* pod"
echo "   File 81, which runs cqlsh into a K8s C* pod"
echo "   File 82, which runs a local cqlsh into a K8s C* pod"
echo ""
echo ""





