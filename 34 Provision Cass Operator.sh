#!/bin/bash


#  From,
#     https://github.com/datastax/cass-operator
#
#


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'helm' and 'kubectl' to provision DataStax Cassandra Kubernetes Operator version 1.5 ..."
echo "   (And make/reset expected namespaces, storage classes, and more.)"
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


kubectl delete namespaces ${MY_NS_OPERATOR}      2> /dev/null               #  suppress spurious error on
kubectl delete namespaces ${MY_NS_CCLUSTER1}     2> /dev/null               #    first run, these ns's will
kubectl delete namespaces ${MY_NS_CCLUSTER2}     2> /dev/null               #    not exist
kubectl delete namespaces ${MY_NS_USER1}         2> /dev/null
kubectl delete namespaces ${MY_NS_USER2}         2> /dev/null
echo ""
   #
kubectl create namespace  ${MY_NS_OPERATOR}
kubectl create namespace  ${MY_NS_CCLUSTER1}
kubectl create namespace  ${MY_NS_CCLUSTER2}
kubectl create namespace  ${MY_NS_USER1}
kubectl create namespace  ${MY_NS_USER2}
echo ""


[ -d C8_CassOperator ] || {
   echo ""
   echo ""
   echo "Error:  This program requires that the DataStax Cassandra Operator Helm Charts"
   echo "        are located in a local sub-folder titled, C8_CassOperator."
   echo ""
   echo "        (We use a local sub-folder, so that we may make changes to default values.)"
   echo ""
   echo "        This required sub-folder is not present."
   echo ""
   echo "        You can download this chart from; https://github.com/datastax/cass-operator"
   echo "        (And then please edit; values.yaml)"
   echo ""
   echo ""
   exit 7
}


#  Expecting helm version 3.x
helm install --namespace=${MY_NS_OPERATOR} cass-operator ./C8_CassOperator
echo ""


kubectl delete storageclass server-storage                2> /dev/null
kubectl create -f C2_storageclass.yaml
# kubectl delete storageclass server-storage-immediate      2> /dev/null
# kubectl create -f C3_C2WithImmediate.yaml


echo ""
echo ""
echo "Next steps:"
echo ""
echo "  Make a Cassandra cluster,"
echo "     40* D1*"
echo ""
echo ""






