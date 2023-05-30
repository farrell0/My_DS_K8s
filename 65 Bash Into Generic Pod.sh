#!/bin/bash


. "./20 Defaults.sh"


##############################################################


l_UserName=`kubectl get pods --namespace=${MY_NS_CCLUSTER1} --no-headers | awk '{print $1}' | head -1 | cut -f1,1 -d'-'`-superuser
   #
CASS_USER=$(kubectl -n ${MY_NS_CCLUSTER1} get secret ${l_UserName} -o json | grep -A2 '"data": {' | grep '"username":' | awk '{print$2}' | sed 's/"//' | base64 --decode 2> /dev/null)
CASS_PASS=$(kubectl -n ${MY_NS_CCLUSTER1} get secret ${l_UserName} -o json | grep -A2 '"data": {' | grep '"password":' | awk '{print$2}' | sed 's/"//' | base64 --decode 2> /dev/null)


l_PodNames=`kubectl describe pods -n ${MY_NS_CCLUSTER1} | grep "^Name:" | awk '{print $2}'`
   #
l_ip_list1=`kubectl -n ${MY_NS_CCLUSTER1} describe pods ${l_PodNames} | grep "^IP:" | awk '{print $2}'`
l_ip_list2=`echo ${l_ip_list1} | sed 's/ /,/g'`


##############################################################


echo ""
echo ""
echo "Calling 'kubectl' to Bash into our Generic Pod ..."
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


##############################################################


echo "Next steps:"
echo ""
echo "   cd /opt"
echo "   . 21*"
echo ""
   #
for t in ${l_ip_list1}
   do
   echo "   cqlsh ${t}  -u ${CASS_USER}  -p ${CASS_PASS}"
   done
   #
echo ""
echo "   To run cassandra-stress, run,"
echo "      /opt/94*"
echo ""
echo ""


kubectl -n ${MY_NS_USER1}  exec -it  generic-pod --  bash








