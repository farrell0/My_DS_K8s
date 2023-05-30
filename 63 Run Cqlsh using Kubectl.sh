#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Use 'kubectl' to run cqlsh(C) from a random C* pod."
echo "   (This program makes a random choice from either C* namespace, with any active pods.)"
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


kubectl get pods -A | egrep "${MY_NS_CCLUSTER1}|${MY_NS_CCLUSTER2}" 
echo ""
echo ""

l_numpods=`kubectl get pods -A | egrep "${MY_NS_CCLUSTER1}|${MY_NS_CCLUSTER2}" | awk '{print $1}' | wc -l`
l_whichpod=`shuf -i 1-${l_numpods} -n 1`
   #
l_ns=`kubectl get pods -A | egrep "${MY_NS_CCLUSTER1}|${MY_NS_CCLUSTER2}" | sed "${l_whichpod},${l_whichpod}"'!d'  | awk '{print $1}'`
l_pod=`kubectl get pods -A | egrep "${MY_NS_CCLUSTER1}|${MY_NS_CCLUSTER2}" | sed "${l_whichpod},${l_whichpod}"'!d' | awk '{print $2}'`

l_secret=`kubectl -n ${l_ns} get pods --no-headers | awk '{print $1}' | head -1 | cut -f1,1 -d'-'`-superuser
   #
CASS_USER=$(kubectl get secret ${l_secret} -n ${l_ns} -o=jsonpath='{.data.username}' | base64 -d)
CASS_PASS=$(kubectl get secret ${l_secret} -n ${l_ns} -o=jsonpath='{.data.password}' | base64 -d)


echo "Running against: ${l_ns}/${l_pod}"
echo "   Username: ${CASS_USER}"
echo "   Password: ${CASS_PASS}"
echo ""
echo ""
   #
kubectl -n ${l_ns} exec -ti ${l_pod} -c cassandra -- sh -c "cqlsh -u '$CASS_USER' -p '$CASS_PASS'"


echo ""
echo ""





