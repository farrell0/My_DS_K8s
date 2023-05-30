#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Use 'kubectl' to run 'nodetool flush' on every Cassandra pod."
echo ""
echo "   (I really only use this program when snapshotting.)"
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


for l_node in `kubectl get pods -n ${MY_NS_CCLUSTER1} --no-headers | awk '{print $1}'`
   do
   echo "Flushing: ${MY_NS_CCLUSTER1}/${l_node}"
   kubectl -n ${MY_NS_CCLUSTER1} exec -it -c cassandra ${l_node} -- nodetool flush
   done

for l_node in `kubectl get pods -n ${MY_NS_CCLUSTER2} --no-headers | awk '{print $1}'`
   do
   echo "Flushing: ${MY_NS_CCLUSTER2}/${l_node}"
   kubectl -n ${MY_NS_CCLUSTER2} exec -it -c cassandra ${l_node} -- nodetool flush
   done

echo ""
echo ""




