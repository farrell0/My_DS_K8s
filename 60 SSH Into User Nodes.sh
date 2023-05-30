#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'gcloud' to ssh into user nodes ..."
echo "   (I don't use this program a whole lot.)"
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
echo "Ps: This first time you run this command, it takes a while to generate keys."
echo "Ps2: If you pass a single number on the command line, 1-N, you will ssh into just that logically numbered node."
echo ""
echo ""
sleep 10


l_cntr=0
l_arg1=${1}


##############################################################


#  Data looks like,
#     
#     NAMESPACE       NAME                                                        READY   STATUS    RESTARTS   AGE
#     cass-operator   cass-operator-55ddb95c99-d4w9c                              1/1     Running   0          69m
#     cass-operator   cluster1-dc1-default-sts-0                                  2/2     Running   0          13m
#     cass-operator   cluster1-dc1-default-sts-1                                  2/2     Running   0          13m
#     cass-operator   cluster1-dc1-default-sts-2                                  2/2     Running   0          13m
#     kube-system     event-exporter-gke-8489df9489-wsfdw                         2/2     Running   0          108m
#     kube-system     fluentd-gke-8vqt9                                           2/2     Running   0          108m
#     kube-system     fluentd-gke-bbnhh                                           2/2     Running   0          108m
#        ...
#     kube-system     fluentd-gke-sqvg5                                           2/2     Running   0          108m
#     kube-system     fluentd-gke-xvls8                                           2/2     Running   0          108m
#     kube-system     gke-metrics-agent-4542p                                     1/1     Running   0          108m
#     kube-system     gke-metrics-agent-5wrhh                                     1/1     Running   0          108m
#     kube-system     gke-metrics-agent-6h6jc                                     1/1     Running   0          108m
#        ...
#     kube-system     gke-metrics-agent-tf99h                                     1/1     Running   0          108m
#     kube-system     gke-metrics-agent-whd52                                     1/1     Running   0          108m
#     kube-system     kube-dns-7c976ddbdb-qgm5x                                   4/4     Running   0          108m
#     kube-system     kube-dns-7c976ddbdb-v25pl                                   4/4     Running   0          108m
#     kube-system     kube-dns-autoscaler-645f7d66cf-v8rl5                        1/1     Running   0          108m
#     kube-system     kube-proxy-gke-farrell-cluster-default-pool-0e147591-cx1f   1/1     Running   0          108m
#     kube-system     kube-proxy-gke-farrell-cluster-default-pool-0e147591-flvz   1/1     Running   0          108m
#        ...
#     kube-system     kube-proxy-gke-farrell-cluster-default-pool-0e147591-rk90   1/1     Running   0          108m
#     kube-system     kube-proxy-gke-farrell-cluster-default-pool-0e147591-zb15   1/1     Running   0          108m
#     kube-system     l7-default-backend-678889f899-b5t9v                         1/1     Running   0          108m
#     kube-system     metrics-server-v0.3.6-97977b449-szn75                       2/2     Running   0          108m
#     kube-system     prometheus-to-sd-5nj99                                      1/1     Running   0          108m
#     kube-system     prometheus-to-sd-gd849                                      1/1     Running   0          108m
#        ...
#     kube-system     prometheus-to-sd-sfkvr                                      1/1     Running   0          108m
#     kube-system     stackdriver-metadata-agent-cluster-level-6497d7c99c-fx7mv   2/2     Running   0          108m


kubectl get pods -A | grep "kube-system" | sed 's/kube-proxy-//' | grep gke-${MY_CLUSTER} 


for l_node in `kubectl get pods -A | grep "kube-system" | sed 's/kube-proxy-//' | grep gke-${MY_CLUSTER} | awk '{print $2}' `
   do

   l_cntr=$((l_cntr+1))
  
   [ ${#} -gt 0 ] && {

      #  Got a command line argument. If this argument is an integer, then
      #  ssh into this node only-

      [[ ${l_arg1} == ?(-)+([0-9]) ]] && {

         [ ${l_arg1} -eq ${l_cntr} ] && {
            echo ""
            echo ""
            echo "Entering node: "${l_node}
            echo "==========================================="
            gcloud compute ssh ubuntu@${l_node} --zone ${GKE_ZONE}
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
      echo "Entering node: "${l_node}
      echo "==========================================="
      echo ""
      gcloud compute ssh ubuntu@${l_node} --zone ${GKE_ZONE}
      echo ""

   }
   
   done





