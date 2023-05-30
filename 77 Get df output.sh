#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'kubectl' to 'df -k' into Cassandra nodes ..."
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


##############################################################


echo ""
echo "C*-Node/K8s-Pod                             Filesystem          Size-GB     Used-GB     Available   Use%  Mounted on"
echo "==========================================  ==================  ==========  ==========  ==========  ====  ===================="

for l_node in `kubectl get pods -A | egrep "${MY_NS_CCLUSTER1}|${MY_NS_CCLUSTER2}" | awk '{printf("%s|%s\n", $1, $2)}'`
   do

   l_ns=`echo  ${l_node} | awk -F "|" '{print $1}'`
   l_pod=`echo ${l_node} | awk -F "|" '{print $2}'`

   kubectl --namespace=${l_ns} exec -it ${l_pod} df 2> /dev/null | \
      grep "/var/lib/cassandra" | awk -v l_node=${l_node} '
         {
         printf("%-42s  %-18s  %-10.2f  %-10.2f  %-10.2f  %4s  %s\n", l_node, $1, $2/1024/1024, $3/1024/1024, $4/1024/1024, $5, $6);
         }'
   
   done

echo ""
echo ""




