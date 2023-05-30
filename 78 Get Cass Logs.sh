#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "This program gets the Cassandra logs from a given Cassandra node (1-N)."
echo ""
echo "(Similar to a 'tail -f', press Control-C to terminate output.)"
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
      
echo ""
echo ""
echo -n "Enter the node number to get Cassandra logs from: "
   #
read l_numb
   #
[ -z ${l_numb} ] && {
   l_numb=0
}


l_cntr=0

for l_node in ${l_cass_pods}
   do
   l_cntr=$((l_cntr+1))
      #
   l_ns=`echo  ${l_node} | awk -F "|" '{print $1}'`
   l_pod=`echo ${l_node} | awk -F "|" '{print $2}'`
      #
   [ ${l_cntr} -eq ${l_numb} ] && {

      kubectl logs -f --namespace=${l_ns} ${l_pod} -c server-system-logger
      
   } || {
      :
   }
   done

echo ""
echo ""





