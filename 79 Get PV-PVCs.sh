#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""

kubectl get pv

echo ""
echo ""

kubectl -n ${MY_NS_CCLUSTER1} get pvc | grep    "^NAME"
echo "Namespace: ${MY_NS_CCLUSTER1}"
kubectl -n ${MY_NS_CCLUSTER1} get pvc | grep -v "^NAME"
echo ""
echo "Namespace: ${MY_NS_CCLUSTER2}"
kubectl -n ${MY_NS_CCLUSTER2} get pvc | grep -v "^NAME"

echo ""
echo ""





