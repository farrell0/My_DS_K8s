#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'kubectl' to Bash into Cassandra nodes (pods) ..."
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
echo "Ps: If you pass a logical pod number, we will Bash into just that pod."
echo ""
echo ""
sleep 10


l_cntr=0
l_arg1=${1}


##############################################################


kubectl get pods -A | egrep "${MY_NS_CCLUSTER1}|${MY_NS_CCLUSTER2}" 


for l_node in `kubectl get pods -A | egrep "${MY_NS_CCLUSTER1}|${MY_NS_CCLUSTER2}" | awk '{printf("%s|%s\n", $1, $2)}'`
   do

   l_cntr=$((l_cntr+1))
      #
   l_ns=`echo  ${l_node} | awk -F "|" '{print $1}'`
   l_pod=`echo ${l_node} | awk -F "|" '{print $2}'`
  
   [ ${#} -gt 0 ] && {

      #  Got a command line argument. If this argument is an integer, then
      #  ssh into this node only-

      [[ ${l_arg1} == ?(-)+([0-9]) ]] && {

         [ ${l_arg1} -eq ${l_cntr} ] && {
            echo ""
            echo ""
            echo "Entering node: ${l_ns}/${l_pod}"
            echo "==========================================="
            kubectl --namespace=${l_ns} exec -it ${l_pod} -- bash
            echo ""
         } || {
            :
         }

      } || {
         echo ""
         echo ""
         echo "ERROR:  You passed a first command line argument that is not an integer."
         echo ""
         echo ""
         exit 1
      }

   } || { 

      echo ""
      echo ""
      echo "Entering node: ${l_ns}/${l_pod}"
      echo "==========================================="
      echo ""
      kubectl --namespace=${l_ns} exec -it ${l_pod} -- bash
      echo ""

   }

   done






