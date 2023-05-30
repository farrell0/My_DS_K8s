#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo "Calling 'kubectl' to make a replica set that we can run a specific demo Web program from ..."
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
echo "**  Your C* cluster and StarGate should be up and running before proceeding."
echo "**  You should create the target keyspace/table/data before reaching this point."
echo "       Run,   82* T4*"
echo ""
echo "**  If this replica set or namespace existed previously, they are dropped and recreated."
echo "       (namespace: ${MY_NS_USER2})"
echo ""
echo "   Edit the ER* YAML file if you have specific changes you want made to this replica set."
echo ""
echo "  .  Currently, /opt, inside the pod, will be writable, and is where you might start looking"
echo "     for things."
echo "  .  This ER YAML expects a Tarball/GZ file on GitHub, containing the Web application we are"
echo "     pushing into this pod."
echo "  .  Want to change the application ?  View what is in the default Tarball, edit it, package"
echo "     it back into a Tarball/GZ, and host the new version of this file yourself."
echo ""
echo ""
sleep 10


##############################################################


#
#  Does the target namespace already exist. If Yes, delete it.
#
l_num_ns=`kubectl get namespaces | grep ${MY_NS_USER2} | wc -l`
   #
[ ${l_num_ns} -eq 0 ] || {
   kubectl delete namespaces ${MY_NS_USER2}
}


##############################################################


kubectl create namespace ${MY_NS_USER2}

#  
#  Copy the secret and service from the K8ssandra namespace into the
#  same namespace where our pod will operate
#
kubectl -n ${MY_K8S_NS} get secret k8ssandra-superuser -o yaml | \
   sed "s/${MY_K8S_NS}/${MY_NS_USER2}/" | \
   kubectl apply -n ${MY_NS_USER2} -f -

kubectl -n ${MY_NS_USER2} create -f ER_geospatial-demo-repset.YAML 


##############################################################


#
#  These pods take a bit of time to actually come up. This wait
#  loop will exit when the pod is ready.
#
l_cntr=0
   #
while :
   do
   l_if_ready=`kubectl get pods -n ${MY_NS_USER2} --no-headers | grep "^geospatial-demo-repset" | grep Running | wc -l`
      #
   [ ${l_if_ready} -gt 0 ] && {
      break 
   } || {
      l_cntr=$((l_cntr+1))
      echo "   Initializing .. ("${l_cntr}")"
         #
      sleep 5
   }
   done

echo "   Initializing .. (complete)"


l_podname=`kubectl get pods -n ${MY_NS_USER2} --no-headers | grep "^geospatial-demo-repset" | head -1 | awk '{print $1}'`


echo ""
echo ""
echo "Next steps:"
echo ""
echo "   Bash into the geo-spatial application demo pod with a,"
echo "      kubectl -n ${MY_NS_USER2} exec -it ${l_podname} -- bash"
echo "         #"
echo "      cd /opt/60_Web_Demo_Program"
echo "      python3 60_index.py"
echo ""
echo "   CQLSH into the target C* cluster,"
echo "      Run 81 or 82"
echo ""
echo "   Run the demo Web program from a local Web browser,"
echo "      You'll need a tunnel to Http port 8084,"
echo ""
echo "      kubectl -n ${MY_NS_USER2} port-forward ${l_podname} 8084:8084"
echo ""
echo "      Then use Url,   localhost:8084"
echo "      to access the Web application"
echo ""
echo ""







