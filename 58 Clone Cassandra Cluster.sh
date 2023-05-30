#!/bin/bash


. "./20 Defaults.sh"


#  If a command line argument is passed, use this as a destination namespace
#
[ ${#} -gt 0 ] && MY_NS_CCLUSTER2 = ${1}


##############################################################
##############################################################


echo ""
echo ""
echo "Calling 'kubectl' to clone an existing Cassandra cluster ..."
echo ""
echo "   .  This program will copy all PVs/PVCs from a source Cassandra cluster, generate"
echo "      the YAML for the destination Cassandra cluster, and call the DataStax Cassandra"
echo "      Operator to instantiate this destination/cloned system. The cloned Cassandra"
echo "      cluster will be left in an operating state (CQL ready)."
echo "   .  This program is tested to work with multiple node/pod Cassandra clusters."
echo "   .  This program will also work with multiple-DC Cassandra clusters, although"
echo "      you may run out of Kubernete worker nodes when cloning on small Kubernetes"
echo "      clusters."
echo "   .  The (source) Cassandra cluster can be up or down, and can remain up or down."
echo "   .  This program calls to 'nodetool flush' the (source) Cassandra cluster before"
echo "      starting the cloning process."
echo "   .  This/a-demo-program, and we hard code copying from a given namespace: ${MY_NS_CCLUSTER1}."
echo "   .  We put the cloned system into the namespace: ${MY_NS_CCLUSTER2}, which is defaulted"
echo "      to a given value, or passed as the first argument on the command line."
echo "   .  If a Cassandra cluster exists in the destination namespace, it is deleted first"
echo "      without first making any backups of same."
echo "   .  Also writing less code, a simpler program; we delete all prior snapshots from"
echo "      the source namespace before making any new snapshots via this program."
echo "   .  Given that we are potentially cloning many GBs of data, this program can take"
echo "      a while to complete. (As a simple script, this program does all work in the"
echo "      foreground/synchronously. That's not a requirement; it's just how we do it.)"
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


##############################################################
##############################################################


l_cntr=`kubectl -n ${MY_NS_CCLUSTER1} get CassandraDatacenter --no-headers | wc -l`

[ ${l_cntr} -eq 0 ] && {

   echo "ERROR:  No Cassandra cluster found to exist in the source namespace, ${MY_NS_CCLUSTER1}"
   echo "        Program terminating. (Nothing to copy from.)" 
   echo ""
   echo ""
   exit 9
}


##############################################################


echo "Step 01 of 08: Running 'nodetool flush' on all nodes in the source Cassandra cluster."
echo "============================================================"
echo ""

for l_node in `kubectl get pods -n ${MY_NS_CCLUSTER1} --no-headers | awk '{print $1}'`
   do
   echo "   Flushing: ${MY_NS_CCLUSTER1}/${l_node}"
   kubectl -n ${MY_NS_CCLUSTER1} exec -it -c cassandra ${l_node} -- nodetool flush
   done

echo ""
echo ""


##############################################################
##############################################################


#  If there is a Cassandra cluster in the target namespace, delete it.
#  If the namespace does not exist, create it.
#
#  We do a lot of manual work here, so that we may produce a rolling
#  status (constant feedback to the operator).


echo "Step 02 of 08: Checking target namespace"
echo "============================================================"
echo ""

l_cntr=`kubectl get ns | grep ${MY_NS_CCLUSTER2} | wc -l`
   #
[ ${l_cntr} -eq 0 ] && {

   echo "Destination namespace does not exist; create it."
   echo ""
   kubectl create namespace ${MY_NS_CCLUSTER2}
   echo ""

} || {

   l_cntr=`kubectl -n ${MY_NS_CCLUSTER2} get CassandraDatacenter --no-headers 2> /dev/null | wc -l`

   [ ${l_cntr} -eq 0 ] || {
   
      echo "A Cassandra cluster exists in the destination namespace, and will be deleted."
      echo "   (Based on sizes, this step can take 2 minutes or more to complete.)"
      echo "   (Using 'kubectl', this is an asynchronous operation which we block on.)"
      echo ""
      echo ""
         #
      l_filename=/tmp/cass-cluster-to-delete.${$}.yaml
      kubectl -n ${MY_NS_CCLUSTER2} get CassandraDatacenter -o yaml > ${l_filename}
      kubectl -n ${MY_NS_CCLUSTER2} delete -f ${l_filename}
         #
      rm -f ${l_filename}
   
      l_cntr=0
         #
      while :
         do
         l_if_ready=`kubectl get pods -n ${MY_NS_CCLUSTER2} --no-headers  2> /dev/null| wc -l`
            #
         [ ${l_if_ready} -gt 0 ] && {
            l_cntr=$((l_cntr+1))
            echo "   Cassandra pods remaining (${l_if_ready}) .. (${l_cntr})"
               #
            sleep 20
         } || {
            break
         }
         done
      
      echo "   Cassandra cluster deletion .. (complete)"
      echo ""
   
      echo ""
      echo "Deleting any leftover PVs from this now deleted Cassandra cluster .."
      echo ""
         #
      for l_pv in `kubectl get pv | grep ${MY_NS_CCLUSTER2} | awk '{print $1}'`
         do
         echo "   Deleting PV: ${l_pv}"
         kubectl delete pv ${l_pv} --grace-period=0 --force 2> /dev/null
         done

   }

   echo "Done"
}

echo ""
echo ""


##############################################################


echo "Step 03 of 08: Checking for presence of Volume Snaphot Class"
echo "============================================================"
echo ""

l_cntr=`kubectl get volumesnapshotclass --no-headers 2> /dev/null | wc -l`

[ ${l_cntr} -eq 0 ] && {

   echo "Creating Volume Snapshot Class .."
   kubectl apply -f X5_CreateVolumeSnapshotClass.yaml

}

echo ""
echo ""


##############################################################


echo "Step 04 of 08: Deleting any past/existing Volume Snaphots"
echo "============================================================"
echo ""

for l_snap in `kubectl -n ${MY_NS_CCLUSTER1} get volumesnapshots --no-headers | awk '{print $1}'`
   do
   kubectl -n ${MY_NS_CCLUSTER1} delete volumesnapshot ${l_snap}
   echo ""
   done

echo ""
echo ""


##############################################################
##############################################################


#  Copying the PVs/PVCs from the source Cassandra clone-

#  Snaphsots are made from PVCs, and the data looks like this,
#     NAME                                     STATUS        VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     AGE
#     server-data-cluster1-dc1-default-sts-0   Terminating   pvc-1c93bd8d-466f-46ab-87a8-85ba40fc2397   5Gi        RWO            server-storage   59m
#
#  Calls to [ complete ] a snapshot are asynchronous, so we block
#  on this and wait for the snaphot to complete.

#  And like all things Kubernetes, this operation needs a YAML,
#  which we generate in the loop below-
#
#  Generally, though this YAML looks similar to,
#     apiVersion: snapshot.storage.k8s.io/v1beta1
#     kind: VolumeSnapshot
#     metadata:
#       name: snapshot-test1
#       namespace: ns-cass-sys1
#     spec:
#       volumeSnapshotClassName: my-snapshot-class
#       source:
#         persistentVolumeClaimName: server-data-cluster1-dc1-default-sts-0

#  3 of the values above must change per iteration of our snapshotting
#  loop


echo "Step 05 of 08: Making Snapshots of source Cassandra cluster"
echo "============================================================"
echo ""

l_cntr1=0
   #
l_str="""
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshot
metadata:
  name: snapshot-XXX
  namespace: YYY
spec:
  volumeSnapshotClassName: my-snapshot-class
  source:
    persistentVolumeClaimName: XXX
"""

for l_pvc in `kubectl -n ${MY_NS_CCLUSTER1} get pvc --no-headers | awk '{print $1}'`
   do
   echo "Snapshotting: ${MY_NS_CCLUSTER1}:${l_pvc}"
      #
   #  Make the YAML for this operation
   #
   l_cntr1=$((l_cntr1+1))
   l_filename=/tmp/cass-snapshot-to-create.${$}.${l_cntr1}.yaml
      #
   echo "${l_str}" | sed "s/XXX/${l_pvc}/" | sed "s/YYY/${MY_NS_CCLUSTER1}/" > ${l_filename}
   #
   #  Initiate the snapshot
   #
   kubectl -n ${MY_NS_CCLUSTER1} apply -f ${l_filename}
      #
   rm -f ${l_filename}
   echo ""
   done

echo ""
echo "** The requested snapshots above operate asynchronously, but we need them"
echo "   to be completed for the next set of steps. So, enter a blocking wait loop."
echo ""

l_cntr2=0
   #
while :
   do
   l_num_ready=`kubectl -n ${MY_NS_CCLUSTER1} describe volumesnapshots 2> /dev/null| \
      grep "Ready To Use:" | grep "true" | wc -l`
      #
   [ ${l_num_ready} -lt ${l_cntr1} ] && {
      l_cntr2=$((l_cntr2+1))
      echo "   Need (${l_cntr1}) snapshots 'Ready/true', Have (${l_num_ready}) .. iteration (${l_cntr2})"
         #
      sleep 20
   } || {
      break
   }
   done

echo "   Done (${l_cntr1}) snaphots are 'Ready/true'."
echo ""
echo ""


##############################################################


echo "Step 06 of 08: From the Snapshots, generate PVs/PVCs"
echo "   (Currently, Kubernetes causes these to be in the source namespace"
echo "    which is not what we want.)"
echo "============================================================"
echo ""

l_str="""
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-snap-XXX
  namespace: YYY
spec:
  dataSource:
    name: ZZZ
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
  storageClassName: server-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
"""

l_cntr=0

for l_pvc in `kubectl -n ${MY_NS_CCLUSTER1} get volumesnapshots --no-headers | awk '{print $1}'`
   do
   l_pvc2=`echo ${l_pvc} | sed 's/^snapshot-//'`
      #
   echo "Creating PV/PVC: ${MY_NS_CCLUSTER1}:${l_pvc2}"
      #
   #  Make the YAML for this operation
   #
   l_cntr=$((l_cntr+1))
   l_filename=/tmp/cass-pvc1-to-create.${$}.${l_cntr}.yaml
      #
   echo "${l_str}" | sed "s/XXX/${l_pvc2}/" | sed "s/YYY/${MY_NS_CCLUSTER1}/" | \
      sed "s/ZZZ/${l_pvc}/" > ${l_filename}
   #
   #  Create the PVs/PVCs
   #
   kubectl -n ${MY_NS_CCLUSTER1} apply -f ${l_filename}
      #
   rm -f ${l_filename}
   echo ""
   done

echo ""
echo "** Similar to many steps above, [ actually populating ] these PVCs is an"
echo "   asynchronous operation. With this version of Kubernetes (1.17/1.18),"
echo "   the best means to finish popluating these PVs/PVCs is to create a pod"
echo "   that targets same. We don't 'need' these pods, we need their existence"
echo "   to force the PVs/PVCs to fill."
echo ""

l_str="""
apiVersion: v1
kind: Pod
metadata:
  name: pod-snap-YYY
spec:
  containers:
  - name: nginx
    image: nginx:1.19.5
    command: ["/bin/bash", "-c"]
    args:
    - |
      sleep infinity & wait
    ports:
    - containerPort: 80
    volumeMounts:
    - name: opt4
      mountPath: /opt4
  dnsPolicy: Default
  volumes:
  - name: opt4
    persistentVolumeClaim:
      claimName: XXX
"""

l_cntr2=0

for l_targ in `kubectl -n ${MY_NS_CCLUSTER1} get pvc --no-headers 2> /dev/null | grep "^pvc-snap-" | awk '{print $1}'`
   do
   l_pod=`echo ${l_targ} | sed "s/^pvc-snap-//"`
      #
   #  Make the YAML for this operation
   #
   l_cntr2=$((l_cntr2+1))
   l_filename=/tmp/cass-pod-to-create.${$}.${l_cntr2}.yaml
      #
   echo "${l_str}" | sed "s/XXX/${l_targ}/" | sed "s/YYY/${l_pod}/" > ${l_filename}
   #
   #  Create the pods
   #
   echo "Creating Pod: ${MY_NS_CCLUSTER1}:${l_pod}"
   kubectl -n ${MY_NS_CCLUSTER1} apply -f ${l_filename}
   echo ""
      #
   rm -f ${l_filename}
   done

echo ""   
echo "Loop, waiting for these (force PV/PVC content) pods to come up."   
echo ""   

l_cntr3=0
   #
while :
   do
   l_num_ready=`kubectl -n ${MY_NS_CCLUSTER1} get pods --no-headers 2> /dev/null| \
      grep "^pod-snap-" | grep "1/1" | grep "Running" | wc -l`
      #
   [ ${l_num_ready} -lt ${l_cntr2} ] && {
      l_cntr3=$((l_cntr3+1))
      echo "   Need (${l_cntr2}) pods 'Running', Have (${l_num_ready}) .. iteration (${l_cntr3})"
         #
      sleep 20
   } || {
      break
   }
   done

echo "   Done (${l_cntr1}) pods are 'Running'."


echo ""
echo "These pods are running, which means that the PVs/PVCs contain the data"
echo "we need."
echo ""
echo "Done with these pods, now we delete them."
echo ""


for l_pod in `kubectl -n ${MY_NS_CCLUSTER1} get pod --no-headers 2> /dev/null | grep "pod-snap-" | awk '{print $1}'`
   do
   echo "Deleting Pod: ${MY_NS_CCLUSTER1}:${l_pod}"
   kubectl -n ${MY_NS_CCLUSTER1} delete pod ${l_pod} --force
   echo ""
   done

echo ""
echo ""


##############################################################


echo "Step 07 of 08: Make PVCs in the destination namespace"
echo "============================================================"
echo "So, a current limitation of Kubernetes 1.17/1.18 ..."
echo ""
echo "   .  We were not [ directly ] able to make the PVCs in the namespace"
echo "      we wanted/needed."
echo "   .  In the last step, we made the PVCs in the source namespace, so we"
echo "      would populate the underlying net new PVs."
echo "   .  Now/here,"
echo "      ..  Delete the source namespace PVCs we no longer need."
echo "      ..  Unbind those underlying PVs."
echo "      ..  Create new PVCs in the correct/destination namespace."
echo ""

l_str="""
apiVersion: "v1"
kind: "PersistentVolumeClaim"
metadata:
  name: YYY
spec:
  storageClassName: server-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: "5Gi"
  volumeName: XXX
"""

for l_target in `kubectl get pv --no-headers 2> /dev/null | awk '{printf("%s/%s\n",$1, $6)}' | \
      grep "${MY_NS_CCLUSTER1}/pvc-snap-"`
   do
   l_pv=`  echo ${l_target} | awk -F "/" '{print $1}'`
   l_pvc1=`echo ${l_target} | awk -F "/" '{print $3}'`
   l_pvc2=`echo ${l_pvc1}   | sed "s/pvc-snap-//"`
      #
   echo "Delete source PVC: ${l_pvc1}"
   kubectl -n ${MY_NS_CCLUSTER1} delete pvc ${l_pvc1} --force 2> /dev/null
      #
   echo "Unbind PV: ${l_pv}"
   kubectl patch pv ${l_pv} -p '{"spec":{"claimRef": null}}'
      #
   #  Make the YAML for this operation
   #
   l_cntr=$((l_cntr+1))
   l_filename=/tmp/cass-pvc2-to-create.${$}.${l_cntr}.yaml
      #
   echo "${l_str}" | sed "s/XXX/${l_pv}/" | sed "s/YYY/${l_pvc2}/" > ${l_filename}
   echo "Create destination PVC: ${l_pvc2}"
   kubectl -n ${MY_NS_CCLUSTER2} apply -f ${l_filename}
   rm -f ${l_filename}
      #
   echo ""
   
   done

echo ""
echo ""


##############################################################


echo "Step 08 of 08: Generate configuration YAML for destination Cassandra"
echo "   cluster and boot same."
echo "============================================================"
echo ""

l_filename="/tmp/cass-cluster-we-cloned.${$}.yaml"
   #
echo "Generating YAML for this cloned Cassandra cluster: ${l_filename}"
   #
kubectl -n ${MY_NS_CCLUSTER1} get CassandraDatacenter -o yaml | \
   sed "s/${MY_NS_CCLUSTER1}/${MY_NS_CCLUSTER2}/g" | \
   sed 's/^    uid: .*/    uid:/' > ${l_filename}
echo "   This YAML is available as file: ${l_filename}"

echo ""
kubectl -n ${MY_NS_CCLUSTER2} apply -f ${l_filename}

echo ""
echo "Waiting for Cassandra cluster to be fully booted. Based on the"
echo "number of Cassandra nodes, this can take 90 seconds or longer."
echo ""

l_cntr1=`kubectl -n ${MY_NS_CCLUSTER1} get pod --no-headers | wc -l`

l_cntr2=0
   #
while :
   do
   l_num_ready=`kubectl -n ${MY_NS_CCLUSTER2} get pod --no-headers 2>/dev/null | \
      sed "s/  */ /g" | grep '2/2 Running' | wc -l`
      #
   [ ${l_num_ready} -lt ${l_cntr1} ] && {
      l_cntr2=$((l_cntr2+1))
      echo "   Need (${l_cntr1}) pods 'Running', Have (${l_num_ready}) .. iteration (${l_cntr2})"
         #
      sleep 20
   } || {
      break
   }
   done

echo "   Done (${l_cntr1}) pods are 'Running'."
echo "   (Cassandra is operational/booted.)"
echo ""
echo "Next steps:"
echo ""
echo "   Run program(s) 63* or 64* to CQLSH into a Cassandra cluster."
echo ""
echo ""






