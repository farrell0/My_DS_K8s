#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Use 'kubectl' to run cqlsh(C) into the K8ssandra C* cluster ..."
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


l_secret=`kubectl -n ${MY_K8S_NS} get pods --no-headers | awk '{print $1}' | head -1 | cut -f1,1 -d'-'`-superuser
   #
CASS_USER=$(kubectl get secret ${l_secret} -n ${MY_K8S_NS} -o=jsonpath='{.data.username}' | base64 -d)
CASS_PASS=$(kubectl get secret ${l_secret} -n ${MY_K8S_NS} -o=jsonpath='{.data.password}' | base64 -d)


echo "Running against: ${MY_K8S_NS}/${MY_K8S_C_NODE}"
echo "   Username: ${CASS_USER}"
echo "   Password: ${CASS_PASS}"
echo ""
echo ""
   #
kubectl -n ${MY_K8S_NS} exec -ti ${MY_K8S_C_NODE} -c cassandra -- sh -c "cqlsh -u '${CASS_USER}' -p '${CASS_PASS}'"


echo ""
echo ""







