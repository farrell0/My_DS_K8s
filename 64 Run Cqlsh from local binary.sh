#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'kubectl' to create a K8s tunnel, and run a local CQLSH ..."
echo "   (If you pass a command line argument, that argument is passed as a 'cqlsh -f \$1' )"
echo ""
echo ""


l_cass_pods=$(kubectl get pods -A | egrep "${MY_NS_CCLUSTER1}|${MY_NS_CCLUSTER2}" | awk '{printf("%s|%s\n", $1, $2)}')
l_cntr=0


for l_node in ${l_cass_pods}
   do

   l_cntr=$((l_cntr+1))
      #
   l_ns=`echo  ${l_node} | awk -F "|" '{print $1}'`
   l_pod=`echo ${l_node} | awk -F "|" '{print $2}'`
      #
   echo "  ${l_cntr}:  ${l_ns}/${l_pod}"
   done


#  Generate a random pod because any given pod may be down for testing
#
l_random_node=`shuf -i 1-${l_cntr} -n 1`
   #
l_this_node=$(echo ${l_cass_pods} | awk -v l_random_node=${l_random_node} '{print $l_random_node}')
   #
l_ns=`echo  ${l_this_node} | awk -F "|" '{print $1}'`
l_pod=`echo ${l_this_node} | awk -F "|" '{print $2}'`


#  Get username, password
#
l_UserName=`kubectl get pods --namespace=${l_ns} --no-headers | awk '{print $1}' | head -1 | cut -f1,1 -d'-'`-superuser
   #
CASS_USER=$(kubectl -n ${l_ns} get secret ${l_UserName} -o json | grep -A2 '"data": {' | grep '"username":' | awk '{print$2}' | sed 's/"//' | base64 --decode 2> /dev/null)
CASS_PASS=$(kubectl -n ${l_ns} get secret ${l_UserName} -o json | grep -A2 '"data": {' | grep '"password":' | awk '{print$2}' | sed 's/"//' | base64 --decode 2> /dev/null)


##############################################################


echo ""
echo ""
echo "Running against: ${l_ns}/${l_pod}"
echo "   Username: ${CASS_USER}"
echo "   Password: ${CASS_PASS}"
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


##############################################################


kubectl port-forward ${l_pod} 9042:9042 -n ${l_ns} &
l_my_pid=${!}
   #
sleep 5


[ ${#} -gt 0 ] && {
   cqlsh -u ${CASS_USER} -p ${CASS_PASS} -f $1
} || {
   cqlsh -u ${CASS_USER} -p ${CASS_PASS} 
}

kill -15 ${l_my_pid}


echo ""
echo ""








