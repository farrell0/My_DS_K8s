#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'kubectl' to set up port forwards for StarGate ..."
echo ""
echo "**  This program will throw an error if K8ssandra is still activating its pods."
echo "**  This program will output to the screen as requests are received on these ports."
echo "       (Thus, you might consider this terminal to now be busy.)"
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


l_secret=`kubectl -n ${MY_K8S_NS} get pods --no-headers | awk '{print $1}' | head -1 | cut -f1,1 -d'-'`-superuser
   #
CASS_USER=$(kubectl get secret ${l_secret} -n ${MY_K8S_NS} -o=jsonpath='{.data.username}' | base64 -d)
CASS_PASS=$(kubectl get secret ${l_secret} -n ${MY_K8S_NS} -o=jsonpath='{.data.password}' | base64 -d)
  #
l_pod=`kubectl -n ${MY_K8S_NS} get pods --no-headers | grep stargate | awk '{print $1}'`


echo "Initiating kubectl port forwarding .."
rm -f /tmp/My_K8ssandra_PortForward.pids
echo ""
   #
kubectl -n ${MY_K8S_NS} port-forward ${l_pod} 8080:8080 &
l_my_pid80=${!}
echo ${l_my_pid80} >  /tmp/My_K8ssandra_PortForward.pids
sleep 5
echo ""
   #
kubectl -n ${MY_K8S_NS} port-forward ${l_pod} 8081:8081 &
l_my_pid81=${!}
echo ${l_my_pid81} >> /tmp/My_K8ssandra_PortForward.pids
sleep 5
echo ""
   #
kubectl -n ${MY_K8S_NS} port-forward ${l_pod} 8082:8082 &
l_my_pid82=${!}
echo ${l_my_pid82} >> /tmp/My_K8ssandra_PortForward.pids
sleep 5
echo ""


l_token=$(curl -L -X POST 'http://localhost:8081/v1/auth' \
   -H 'Content-Type: application/json' \
   --data-raw "{ \"username\": \"${CASS_USER}\", \"password\": \"${CASS_PASS}\" }" \
      2> /dev/null | jq -r  '.authToken')


echo ""
echo ""
echo "Next Steps:"
echo ""
echo "   GraphQL is at, 8080"
echo "      http://localhost:8080/playground"
echo ""
echo "   Auth token is at, 8081"
echo "      A current/valid token is: ${l_token}"
echo ""
echo "   REST, including Document API, are at, 8082"
echo "      http://localhost:8082/swagger-ui"
echo ""
echo "   CQL is at, 9042"
echo "      Run program 82*" 
echo ""
echo ""







