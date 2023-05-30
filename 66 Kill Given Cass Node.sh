#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'kubectl' to kill a given Cassandra node ..."
echo "   (The node is flushed before it is killed.)"
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


##############################################################


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


echo ""
echo ""
echo -n "Enter the node number to kill: "
   #
read l_numb
   #
[ -z ${l_numb} ] && {
   l_numb=0
}


##############################################################


l_cntr=0

for l_node in ${l_cass_pods}
   do

   l_cntr=$((l_cntr+1))
      #
   [ ${l_cntr} -eq ${l_numb} ] && {

      l_ns=`echo  ${l_node} | awk -F "|" '{print $1}'`
      l_pod=`echo ${l_node} | awk -F "|" '{print $2}'`

      kubectl -n ${l_ns} exec -it -c cassandra ${l_pod} -- nodetool flush
      kubectl --namespace=${l_ns} delete pods  ${l_pod} --grace-period=0 --force

   } || {
      :
   }

   done

echo ""
echo ""
echo "Next steps:"
echo "   watch kubectl get pods -n ${l_ns}"
echo "   kubectl get pods -n ${l_ns} -w"
echo ""
echo ""









