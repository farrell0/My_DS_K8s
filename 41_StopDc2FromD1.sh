#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'kubectl' to drop DC2 from cluster1 ..."
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


kubectl delete -f D5_D1AddSecondDcWith2Nodes.yaml


echo ""
echo ""




