#!/bin/bash


. "./20 Defaults.sh"


#  nodetool currently requires a password for the JMX user .. .. so
#  this program is curreently broken'ish


##############################################################


echo ""
echo ""
echo "Calling 'kubectl' to Bash into K8ssandra C* cluster ..."
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

echo "Next steps:"
echo ""
echo "   nodetool -u ${CASS_USER} -pw ${CASS_PASS} status"


#  Kind of a hack here; how to id a C* node by name
#
for l_pod in `kubectl -n ${MY_K8S_NS} get pods | awk '{print $1}' | grep default-sts`
   do

   echo ""
   echo "Entering node: ${MY_K8S_ns}/${l_pod}"
   echo "==========================================="
   kubectl --namespace=${MY_K8S_NS} exec -it ${l_pod} -- bash
   echo ""

   done





