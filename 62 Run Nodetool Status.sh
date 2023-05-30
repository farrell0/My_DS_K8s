#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Use 'kubectl' to run nodetool status. With our testing, any given"
echo "C* node may be down. So, run this from a random C* node."
echo ""
echo "(So, if this program fails, run it again.)"
echo ""
echo ""

#  shuf(C) generates a random number-
#
#  Why we're doing this;  Any given node may be down.

l_num_nodes=`kubectl get pods -A | egrep "${MY_NS_CCLUSTER1}|${MY_NS_CCLUSTER2}" | wc -l`
l_which_node=`shuf -i 1-${l_num_nodes} -n 1`
   #
l_ns=`  kubectl get pods -A | egrep "${MY_NS_CCLUSTER1}|${MY_NS_CCLUSTER2}" | sed ${l_which_node}'!d' | awk '{print $1}'`
l_node=`kubectl get pods -A | egrep "${MY_NS_CCLUSTER1}|${MY_NS_CCLUSTER2}" | sed ${l_which_node}'!d' | awk '{print $2}'`

echo "Running from namespace/node: ${l_ns}/${l_node}"
echo ""
kubectl -n ${l_ns} exec -it -c cassandra ${l_node} -- nodetool status

echo ""
echo ""

