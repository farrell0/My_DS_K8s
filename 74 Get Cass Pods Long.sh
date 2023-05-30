#!/bin/bash


#  Formatted report from 'kubectl describe nodes' with emphasis 
#  on the Cassandra cluster

#  'kubectl describe nodes' did not support '-o json' at the 
#   time I created this program-

#  Input looks like this, (repeated over each node) ..
#
#   Name:               gke-farrell-cluster-default-pool-b51a8c5c-0jmc
#   Roles:              <none>
#   Labels:             beta.kubernetes.io/arch=amd64
#                       beta.kubernetes.io/instance-type=n2-standard-8
#                       beta.kubernetes.io/os=linux
#                       cloud.google.com/gke-nodepool=default-pool
#                       cloud.google.com/gke-os-distribution=cos
#                       failure-domain.beta.kubernetes.io/region=us-central1
#                       failure-domain.beta.kubernetes.io/zone=us-central1-a
#                       kubernetes.io/arch=amd64
#                       kubernetes.io/hostname=gke-farrell-cluster-default-pool-b51a8c5c-0jmc
#                       kubernetes.io/os=linux
#   Annotations:        container.googleapis.com/instance_id: 1631541680007170157
#                       node.alpha.kubernetes.io/ttl: 0
#                       node.gke.io/last-applied-node-labels: cloud.google.com/gke-nodepool=default-pool,cloud.google.com/gke-os-distribution=cos
#                       volumes.kubernetes.io/controller-managed-attach-detach: true
#   CreationTimestamp:  Thu, 26 Nov 2020 10:42:49 -0800
#   Taints:             <none>
#   Unschedulable:      false
#   Lease:
#     HolderIdentity:  gke-farrell-cluster-default-pool-b51a8c5c-0jmc
#     AcquireTime:     <unset>
#     RenewTime:       Thu, 26 Nov 2020 11:06:30 -0800
#   Conditions:
#     Type                          Status  LastHeartbeatTime                 LastTransitionTime                Reason                          Message
#     ----                          ------  -----------------                 ------------------                ------                          -------
#     FrequentUnregisterNetDevice   False   Thu, 26 Nov 2020 11:02:51 -0800   Thu, 26 Nov 2020 10:42:49 -0800   NoFrequentUnregisterNetDevice   node is functioning properly
#     FrequentKubeletRestart        False   Thu, 26 Nov 2020 11:02:51 -0800   Thu, 26 Nov 2020 10:42:49 -0800   NoFrequentKubeletRestart        kubelet is functioning properly
#     FrequentDockerRestart         False   Thu, 26 Nov 2020 11:02:51 -0800   Thu, 26 Nov 2020 10:42:49 -0800   NoFrequentDockerRestart         docker is functioning properly
#     FrequentContainerdRestart     False   Thu, 26 Nov 2020 11:02:51 -0800   Thu, 26 Nov 2020 10:42:49 -0800   NoFrequentContainerdRestart     containerd is functioning properly
#     KernelDeadlock                False   Thu, 26 Nov 2020 11:02:51 -0800   Thu, 26 Nov 2020 10:42:49 -0800   KernelHasNoDeadlock             kernel has no deadlock
#     ReadonlyFilesystem            False   Thu, 26 Nov 2020 11:02:51 -0800   Thu, 26 Nov 2020 10:42:49 -0800   FilesystemIsNotReadOnly         Filesystem is not read-only
#     CorruptDockerOverlay2         False   Thu, 26 Nov 2020 11:02:51 -0800   Thu, 26 Nov 2020 10:42:49 -0800   NoCorruptDockerOverlay2         docker overlay2 is functioning properly
#     NetworkUnavailable            False   Thu, 26 Nov 2020 10:42:50 -0800   Thu, 26 Nov 2020 10:42:50 -0800   RouteCreated                    NodeController create implicit route
#     MemoryPressure                False   Thu, 26 Nov 2020 11:06:24 -0800   Thu, 26 Nov 2020 10:42:49 -0800   KubeletHasSufficientMemory      kubelet has sufficient memory available
#     DiskPressure                  False   Thu, 26 Nov 2020 11:06:24 -0800   Thu, 26 Nov 2020 10:42:49 -0800   KubeletHasNoDiskPressure        kubelet has no disk pressure
#     PIDPressure                   False   Thu, 26 Nov 2020 11:06:24 -0800   Thu, 26 Nov 2020 10:42:49 -0800   KubeletHasSufficientPID         kubelet has sufficient PID available
#     Ready                         True    Thu, 26 Nov 2020 11:06:24 -0800   Thu, 26 Nov 2020 10:42:49 -0800   KubeletReady                    kubelet is posting ready status. AppArmor enabled
#   Addresses:
#     InternalIP:   10.128.0.26
#     ExternalIP:   34.72.38.59
#     InternalDNS:  gke-farrell-cluster-default-pool-b51a8c5c-0jmc.c.gke-launcher-dev.internal
#     Hostname:     gke-farrell-cluster-default-pool-b51a8c5c-0jmc.c.gke-launcher-dev.internal
#   Capacity:
#     attachable-volumes-gce-pd:  127
#     cpu:                        8
#     ephemeral-storage:          1027832452Ki
#     hugepages-2Mi:              0
#     memory:                     32944200Ki
#     pods:                       110
#   Allocatable:
#     attachable-volumes-gce-pd:  127
#     cpu:                        7910m
#     ephemeral-storage:          839876203795
#     hugepages-2Mi:              0
#     memory:                     29149256Ki
#     pods:                       110
#   System Info:
#     Machine ID:                 19ab071a9e29ad5412e7aab4bc67fd7d
#     System UUID:                19ab071a-9e29-ad54-12e7-aab4bc67fd7d
#     Boot ID:                    e86f4e92-1da1-4783-acba-39c8af745e88
#     Kernel Version:             4.19.112+
#     OS Image:                   Container-Optimized OS from Google
#     Operating System:           linux
#     Architecture:               amd64
#     Container Runtime Version:  docker://19.3.1
#     Kubelet Version:            v1.16.13-gke.401
#     Kube-Proxy Version:         v1.16.13-gke.401
#   PodCIDR:                      10.0.2.0/24
#   PodCIDRs:                     10.0.2.0/24
#   ProviderID:                   gce://gke-launcher-dev/us-central1-a/gke-farrell-cluster-default-pool-b51a8c5c-0jmc
#   Non-terminated Pods:          (7 in total)
#     Namespace                   Name                                                         CPU Requests  CPU Limits  Memory Requests  Memory Limits  AGE
#     ---------                   ----                                                         ------------  ----------  ---------------  -------------  ---
#     kube-system                 fluentd-gke-qbll4                                            100m (1%)     1 (12%)     200Mi (0%)       500Mi (1%)     22m
#     kube-system                 fluentd-gke-scaler-cd4d654d7-hcpl5                           0 (0%)        0 (0%)      0 (0%)           0 (0%)         23m
#     kube-system                 gke-metrics-agent-qfk6r                                      3m (0%)       0 (0%)      50Mi (0%)        50Mi (0%)      23m
#     kube-system                 kube-proxy-gke-farrell-cluster-default-pool-b51a8c5c-0jmc    100m (1%)     0 (0%)      0 (0%)           0 (0%)         23m
#     kube-system                 metrics-server-v0.3.6-64655c969-ml6ln                        48m (0%)      143m (1%)   105Mi (0%)       355Mi (1%)     23m
#     kube-system                 prometheus-to-sd-wk28v                                       0 (0%)        0 (0%)      0 (0%)           0 (0%)         23m
#     kube-system                 stackdriver-metadata-agent-cluster-level-6497d7c99c-6qvc9    98m (1%)      48m (0%)    202Mi (0%)       202Mi (0%)     23m
#   Allocated resources:
#     (Total limits may be over 100 percent, i.e., overcommitted.)
#     Resource                   Requests    Limits
#     --------                   --------    ------
#     cpu                        349m (4%)   1191m (15%)
#     memory                     557Mi (1%)  1107Mi (3%)
#     ephemeral-storage          0 (0%)      0 (0%)
#     hugepages-2Mi              0 (0%)      0 (0%)
#     attachable-volumes-gce-pd  0           0
#   Events:
#     Type     Reason                   Age                From             Message
#     ----     ------                   ----               ----             -------
#     Normal   Starting                 23m                kubelet          Starting kubelet.
#     Normal   NodeHasSufficientMemory  23m (x2 over 23m)  kubelet          Node gke-farrell-cluster-default-pool-b51a8c5c-0jmc status is now: NodeHasSufficientMemory
#     Normal   NodeHasNoDiskPressure    23m (x2 over 23m)  kubelet          Node gke-farrell-cluster-default-pool-b51a8c5c-0jmc status is now: NodeHasNoDiskPressure
#     Normal   NodeHasSufficientPID     23m (x2 over 23m)  kubelet          Node gke-farrell-cluster-default-pool-b51a8c5c-0jmc status is now: NodeHasSufficientPID
#     Normal   NodeAllocatableEnforced  23m                kubelet          Updated Node Allocatable limit across pods
#     Warning  ContainerdStart          23m                systemd-monitor  Starting containerd container runtime...
#     Warning  DockerStart              23m (x2 over 23m)  systemd-monitor  Starting Docker Application Container Engine...
#     Warning  KubeletStart             23m (x5 over 23m)  systemd-monitor  Started Kubernetes kubelet.
#     Normal   NodeReady                23m                kubelet          Node gke-farrell-cluster-default-pool-b51a8c5c-0jmc status is now: NodeReady
#     Normal   Starting                 23m                kube-proxy       Starting kube-proxy.


##############################################################


. "./20 Defaults.sh"


##############################################################


kubectl describe nodes | awk -v l_ns1=${MY_NS_CCLUSTER1} -v l_ns2=${MY_NS_CCLUSTER2} '
   {

   if ($1 == "Name:") {
      print ""
      print ""
      print $0
      print "==================  ====================================================="
      }
   else if ($1 == "Addresses:") {
      print $0
      }
   else if ($1 == "InternalIP:") {
      print $0
      }
   else if ($1 == "ExternalIP:") {
      print $0
      }
   else if ($1 == "Non-terminated") {
      print $0
      }
   else if ($1 == "Namespace") {
      print $0
      print "  ---------                   ----                                                         ------------  ----------  ---------------  -------------  ---"
      }
   else if ($1 == l_ns1) {
      print $0
      }
   else if ($1 == l_ns2) {
      print $0
      }

   }   '

echo ""
echo ""




