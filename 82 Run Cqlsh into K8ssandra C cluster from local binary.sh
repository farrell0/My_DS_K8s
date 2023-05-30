#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'kubectl' to create a K8s tunnel, and run a local CQLSH ..."
echo "   (If you pass a command line argument, that argument is passed as a 'cqlsh -f \$1' )"
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


##############################################################


l_secret=`kubectl -n ${MY_K8S_NS} get pods --no-headers | awk '{print $1}' | head -1 | cut -f1,1 -d'-'`-superuser
   #
CASS_USER=$(kubectl get secret ${l_secret} -n ${MY_K8S_NS} -o=jsonpath='{.data.username}' | base64 -d)
CASS_PASS=$(kubectl get secret ${l_secret} -n ${MY_K8S_NS} -o=jsonpath='{.data.password}' | base64 -d)

l_pod=`kubectl -n ${MY_K8S_NS} get pods --no-headers | awk '{print $1}' | grep default-sts`


##############################################################


kubectl port-forward ${l_pod} 9042:9042 -n ${MY_K8S_NS} &
l_my_pid=${!}
   #
sleep 5


[ ${#} -gt 0 ] && {
   cqlsh -u ${CASS_USER} -p ${CASS_PASS} -u ${CASS_USER} -p ${CASS_PASS} -f ${1}
} || {
   cqlsh -u ${CASS_USER} -p ${CASS_PASS} -u ${CASS_USER} -p ${CASS_PASS}
}

kill -15 ${l_my_pid}


echo ""
echo ""






