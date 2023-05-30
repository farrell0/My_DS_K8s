#!/bin/bash


. "./20 Defaults.sh"


echo ""
echo ""
echo "Press CONTROL-C to quit ..."
echo ""
echo ""

while true
   do
   kubectl get pods -n ${MY_NS_CCLUSTER1} | grep "^NAME"
   echo "namespace ${MY_NS_CCLUSTER1}"
   kubectl get pods -n ${MY_NS_CCLUSTER1} --no-headers
   echo ""
   echo "namespace ${MY_NS_CCLUSTER2}"
   kubectl get pods -n ${MY_NS_CCLUSTER2} --no-headers
   echo ""
   echo ""
   sleep 5
   done

echo ""
echo ""




