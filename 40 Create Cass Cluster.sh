#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'kubectl' to apply the Cassandra Cluster YAML file ..."
echo "   (Create or change a Cassandra cluster.)"
echo ""
echo "   Right now:"
echo "      D1 - makes the first C* cluster, 1 node"
echo "      D2 - shuts down D1"
echo "      D4 - D1, with 3 nodes"
echo "      D5 - D1, add a second DC (dc2) with 2 nodes"
echo ""
echo "      D8 - similar to D1, but makes a second C* cluster in another namespace"
echo "      D9 - shuts down D8"
echo ""
echo "   Edit the given YAML file if you have specific changes you want made."
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


echo ""
echo ""
echo -n "Enter the YAML file number to apply (default is D1): "
   #
[ ${#} -gt 0 ] && {
   l_numb=${1}
} || {
   read l_numb
}
   #
[ -z ${l_numb} ] && {
   l_numb=D1
}


##############################################################


echo ""
echo ""

kubectl apply -f ${l_numb}*


echo ""
echo ""
echo "Next steps:"
echo ""
echo "   watch kubectl -n ${MY_NS_CCLUSTER1} get pods"
echo "   watch kubectl -n ${MY_NS_CCLUSTER2} get pods"
echo ""
echo "   Look for all pods 'Running'"
echo "   Example:"
echo "      cluster1-dc1-default-sts-0   2/2     Running   0          2m38s"
echo ""
echo ""
echo "   Put a table and some data in this cluster ?"
echo "      64* T1*"
echo "   Then flush ?"
echo "      67*"
echo ""
echo ""



