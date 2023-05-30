#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo "Calling 'kubectl' to make a replica set that we can run a stand alone StarGate from ..."
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
echo "**  Your [ DataStax Cassandra Operator managed ] C* or DSE cluster should be up and running"
echo "    in (namespace: ${MY_NS_CCLUSTER1}) before proceeding."
echo "**  If the StarGate replica set or namespace existed previously, they are dropped and recreated."
echo "       (namespace: ${MY_NS_USER2})"
echo "**  Edit the ES* YAML file if you have specific changes you want made to this replica set."
echo ""
echo "  .  Currently, /opt/stargate, inside the pod, will be writable, and is where you might start"
echo "     looking for things."
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
#  Copy the secret and service from the DSE/C* namespace into the
#  same namespace where our pod will operate
#
#  **  I'm not currently using these values, or this secret, just fyi.
#
l_secret=cluster1-superuser
   #
kubectl -n ${MY_NS_CCLUSTER1} get secret ${l_secret} -o yaml | \
   sed "s/${MY_NS_CCLUSTER1}/${MY_NS_USER2}/" | \
   kubectl apply -n ${MY_NS_USER2} -f -


l_CASS_podip=`kubectl describe pods -n ${MY_NS_CCLUSTER1} | grep "^IP:" | head -1 | awk '{print $2}'`
   #
CASS_USER=$(kubectl get secret ${l_secret} -n ${MY_NS_CCLUSTER1} -o=jsonpath='{.data.username}' | base64 -d)
CASS_PASS=$(kubectl get secret ${l_secret} -n ${MY_NS_CCLUSTER1} -o=jsonpath='{.data.password}' | base64 -d)

#
#  Create a secret with most data needed by StarGate
#
echo """
apiVersion: v1
kind: Secret
metadata:
  name: dse-conn-details
type: Opaque
stringData:
  cluster-name: cluster1
  cluster-seed: \"${l_CASS_podip}\"
  cluster-version: \"6.8\"
  listen: TBD
  dc: dc1
  rack: default

""" | kubectl apply -n ${MY_NS_USER2} -f -



kubectl -n ${MY_NS_USER2} create -f ES_stargate-repset.YAML 


##############################################################


#
#  These pods take a bit of time to actually come up. This wait
#  loop will exit when the pod is ready.
#
l_cntr=0
   #
while :
   do
   l_if_ready=`kubectl get pods -n ${MY_NS_USER2} --no-headers | grep "^stargate-repset" | grep Running | wc -l`
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


##############################################################


l_SG_podname=`kubectl get pods -n ${MY_NS_USER2} --no-headers | grep "^stargate-repset" | head -1 | awk '{print $1}'`
l_SG_podip=`kubectl describe pods -n ${MY_NS_USER2} | grep "^IP:" | head -1 | awk '{print $2}'`


echo ""
echo ""
echo "Next steps:"
echo ""
echo "   CQLSH into the target C* cluster,"
echo "      Run 63 or 64 *"
echo ""
echo "   Bash into the StarGate Replica Set application pod with a,"
echo "      kubectl -n ${MY_NS_USER2} exec -it ${l_SG_podname} -- bash"
echo "         #"
echo "      cd /opt/stargate"
echo ""
echo "   Test/run StarGate ?"
echo "      You'll need a tunnel to Http port 8080, 8081, 8082"
echo ""
echo "      kubectl -n ${MY_NS_USER2} port-forward ${l_SG_podname} 8080:8080 &"
echo '      my_pid80=${!}'
echo "      kubectl -n ${MY_NS_USER2} port-forward ${l_SG_podname} 8081:8081 &"
echo '      my_pid81=${!}'
echo "      kubectl -n ${MY_NS_USER2} port-forward ${l_SG_podname} 8082:8082 &"
echo '      my_pid82=${!}'
echo "         #"
echo '      kill -15 ${my_pid80} ${my_pid81} ${my_pid82}'
echo ""
echo ""
echo "      Get a StarGate Auth token ?"
echo ""
echo "         l_token=\$(curl -L -X POST 'http://localhost:8081/v1/auth' -H 'Content-Type: application/json' --data-raw '{ \"username\": \"${CASS_USER}\", \"password\": \"${CASS_PASS}\" }' | jq -r '.authToken')"
echo ""
echo ""








