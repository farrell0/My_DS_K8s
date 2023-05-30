#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'kubectl' to destroy port forwards for StarGate ..."
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


echo "Destroying kubectl port forwarding .."

for t in `cat /tmp/My_K8ssandra_PortForward.pids`
   do
   kill -15 ${t}
   done

rm -f /tmp/My_K8ssandra_PortForward.pids


echo ""
echo ""





