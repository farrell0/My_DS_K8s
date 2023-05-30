#!/bin/bash


. "./20 Defaults.sh"


##############################################################


l_UserName=`kubectl get pods --namespace=${MY_NS_CCLUSTER1} --no-headers | awk '{print $1}' | head -1 | cut -f1,1 -d'-'`-superuser
   #
CASS_USER=$(kubectl -n ${MY_NS_CCLUSTER1} get secret ${l_UserName} -o json | grep -A2 '"data": {' | grep '"username":' | awk '{print$2}' | sed 's/"//' | base64 --decode 2> /dev/null)
CASS_PASS=$(kubectl -n ${MY_NS_CCLUSTER1} get secret ${l_UserName} -o json | grep -A2 '"data": {' | grep '"password":' | awk '{print$2}' | sed 's/"//' | base64 --decode 2> /dev/null)

#
#  Get a list of internal IPs, pods that run a C* node
#
l_PodNames=`kubectl describe pods -n ${MY_NS_CCLUSTER1} | grep "^Name:" | awk '{print $2}'`
   #
l_ip_list1=`kubectl -n ${MY_NS_CCLUSTER1} describe pods ${l_PodNames} | grep "^IP:" | awk '{print $2}'`
l_ip_list2=`echo ${l_ip_list1} | sed 's/ /,/g'`


echo ""                                                                 >  21_DefaultsOnGenericPod.sh
echo ""                                                                 >> 21_DefaultsOnGenericPod.sh
echo "CASS_USER=${CASS_USER}"                                           >> 21_DefaultsOnGenericPod.sh
echo "CASS_PASS=${CASS_PASS}"                                           >> 21_DefaultsOnGenericPod.sh
echo ""                                                                 >> 21_DefaultsOnGenericPod.sh
echo "IP_LIST=${l_ip_list2}"                                            >> 21_DefaultsOnGenericPod.sh
echo ""                                                                 >> 21_DefaultsOnGenericPod.sh
echo "export PATH=\${PATH}:/opt/cassandra/bin"                          >> 21_DefaultsOnGenericPod.sh
echo "export PATH=\${PATH}:/opt/cassandra/tools/bin"                    >> 21_DefaultsOnGenericPod.sh
echo "export PATH=\${PATH}:/usr/lib/jvm/java-11-openjdk-amd64/bin"      >> 21_DefaultsOnGenericPod.sh
echo "export PATH=\${PATH}:."                                           >> 21_DefaultsOnGenericPod.sh
echo ""                                                                 >> 21_DefaultsOnGenericPod.sh
echo ""                                                                 >> 21_DefaultsOnGenericPod.sh
echo ""                                                                 >> 21_DefaultsOnGenericPod.sh
echo ""                                                                 >> 21_DefaultsOnGenericPod.sh
   #
chmod 777                                                                  21_DefaultsOnGenericPod.sh


##############################################################


echo ""
echo "Calling 'kubectl' to make a generic pod/container that we can run C* clients from ..."
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo "**  If this pod or namespace existed previously, they are dropped and recreated."
echo "**  Your C* cluster should be up and running before proceeding."
echo "**  This program hard codes access to the first C* namespace only: ${MY_NS_CCLUSTER1}"
echo ""
echo ""
echo "Edit the E1* YAML file if you have specific changes you want made."
echo "  (Currently, /opt, inside the pod, will be writable.)"
echo ""
echo ""
sleep 10


##############################################################


#
#  Are there any existing pods. If Yes, kill them.
#
l_num_pods=`kubectl get pods -A | grep ${MY_NS_USER1} | grep generic-pod | wc -l`
   #
[ ${l_num_pods} -eq 0 ] || {
   kubectl -n ${MY_NS_USER1}  delete pods generic-pod --grace-period=0
}
#
#  Does the target namespace already exist. If Yes, delete it.
#
l_num_ns=`kubectl get namespaces | grep ${MY_NS_USER1} | wc -l`
   #
[ ${l_num_ns} -eq 0 ] || {
   kubectl delete namespaces ${MY_NS_USER1}
}


##############################################################


kubectl create namespace ${MY_NS_USER1}

echo ""

kubectl -n ${MY_NS_USER1} create -f E1_generic_pod.yaml


##############################################################


#
#  These pods take a bit of time to actually come up. This wait
#  loop will exit when the pod is ready.
#
l_cntr=0
   #
while :
   do
   l_if_ready=`kubectl get pods -n ${MY_NS_USER1} --no-headers | grep "^generic-pod" | grep Running | wc -l`
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
echo "   File copies .."
   #
kubectl -n ${MY_NS_USER1}  cp 94_RunStressOnGenPod.sh       generic-pod:/opt/94_RunStressOnGenPod.sh   
kubectl -n ${MY_NS_USER1}  cp 21_DefaultsOnGenericPod.sh    generic-pod:/opt/21_DefaultsOnGenericPod.sh


echo ""
echo ""
echo "Next steps:"
echo "   Login to this pod by running file 65*"
echo ""
echo ""



