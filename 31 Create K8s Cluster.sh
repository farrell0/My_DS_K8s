#!/bin/bash


#  GCP machines types,
#
#     https://cloud.google.com/compute/docs/machine-types#n2_machine_types
#     https://cloud.google.com/compute/docs/regions-zones#available
#
#   gcloud compute zones list

#  Which versions are avail ?
#
#     gcloud container get-server-config --format "yaml(channels)" --zone ${GKE_ZONE}
#        Fetching server config for us-central1-a
#        channels:
#        - channel: RAPID
#          defaultVersion: 1.18.12-gke.1200
#          validVersions:
#          - 1.18.12-gke.1201
#          - 1.18.12-gke.1200
#        - channel: REGULAR
#          defaultVersion: 1.17.13-gke.2600
#          validVersions:
#          - 1.17.14-gke.400
#          - 1.17.13-gke.2600
#        - channel: STABLE
#          defaultVersion: 1.16.15-gke.4901
#          validVersions:
#          - 1.16.15-gke.5500
#          - 1.16.15-gke.4901
#          - 1.16.15-gke.4301
#          - 1.16.15-gke.4300
#          - 1.15.12-gke.6002
#          - 1.15.12-gke.6001
#          - 1.15.12-gke.20


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'gcloud' to create K8s cluster ..."
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10

#    --machine-type "n2-standard-16"    
#    --disk-type "pd-ssd"    \

gcloud beta container --project ${GKE_PROJECT}   \
   clusters create ${MY_CLUSTER}    \
   --zone ${GKE_ZONE}    \
   --no-enable-basic-auth    \
   --cluster-version "1.19.15-gke.1801" \
   --addons=GcePersistentDiskCsiDriver \
   --machine-type "n2-standard-8"    \
   --image-type "COS"    \
   --disk-type "pd-standard"    \
   --disk-size "500"    \
   --metadata disable-legacy-endpoints=true    \
   --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append"    \
   --num-nodes "6"    \
   --enable-stackdriver-kubernetes    \
   --enable-ip-alias    \
   --default-max-pods-per-node "110"    \
   --no-enable-master-authorized-networks    


#  Moving to a 'rapid' channel release, K8s 1.18 and higher
#
#  From,
#     https://cloud.google.com/kubernetes-engine/docs/how-to/upgrading-a-cluster
#
#  Supported rapid channel versions,
#     https://cloud.google.com/kubernetes-engine/docs/release-notes-rapid
#
#    echo ""
#    gcloud container clusters update ${MY_CLUSTER} --release-channel rapid
#    gcloud container clusters upgrade -q ${MY_CLUSTER} --master --cluster-version "1.18.12-gke.1205"
#    gcloud container clusters upgrade -q ${MY_CLUSTER}


##############################################################


#
#  Stuff needed for Velero
#

# echo ""
# echo "Create GCP block storage ..."
#    #
# gsutil mb gs://${MY_BUCKET}/


# echo ""
# echo "Add Velero to the Kubernetes cluster ..."
#    #
# chmod 600 24_credentials_velero.txt
# velero install \
#    --provider gcp \
#    --plugins velero/velero-plugin-for-gcp:v1.1.0 \
#    --bucket ${MY_BUCKET} \
#    --use-volume-snapshots=false \
#    --secret-file ./24_credentials_velero.txt


#  These/below are a subset of all commands needed to setup Velero-
#
#  The commands below are GCP/GKE project specfic
#
#  See file 01 for the complete Velero install discussion-
#
# SERVICE_ACCOUNT_EMAIL=$(gcloud iam service-accounts list \
#    --filter="displayName:Velero service account" \
#    --format 'value(email)')
# 
# echo ""
# gcloud projects add-iam-policy-binding ${GKE_PROJECT} \
#    --member serviceAccount:$SERVICE_ACCOUNT_EMAIL \
#    --role projects/${GKE_PROJECT}/roles/velero.server
# 
# echo ""
# gsutil iam ch serviceAccount:$SERVICE_ACCOUNT_EMAIL:objectAdmin gs://${MY_BUCKET}


##############################################################


#
#  Stuff needed for Kasten
#

# echo ""
# echo "Add Kasten to the Kubernetes cluster ..."
#    #
# helm repo add    kasten https://charts.kasten.io/
# kubectl create namespace kasten-io
#    #
# kubectl apply -f X6_CreateKastenVolumeSnapshotClass.yaml
# 
# curl https://docs.kasten.io/tools/k10_primer.sh | bash


#
#  svc accts
#
# myproject=$(gcloud config get-value core/project)
# gcloud iam service-accounts create k10-test-sa --display-name "K10 Service Account" 2> /dev/null         #  harmless fail on repetitive execution
# k10saemail=$(gcloud iam service-accounts list --filter "k10-test-sa" --format="value(email)")

#
#  If we run this program enough times, we run out of these key slots; like 10 max.
#
# for t in `gcloud iam service-accounts keys list --iam-account=${k10saemail} | grep -v '9999-12-31' | grep -v 'KEY_ID' | awk '{print $1}'`
# do
# gcloud iam service-accounts keys delete $t --iam-account=${k10saemail} --quiet   2> /dev/null
# done

# gcloud iam service-accounts keys create --iam-account=${k10saemail} K2_k10-sa-key.json
# gcloud projects add-iam-policy-binding ${myproject} --member serviceAccount:${k10saemail} --role roles/compute.storageAdmin


# sa_key=$(base64 -w0 K2_k10-sa-key.json)
# helm install k10 kasten/k10 --namespace=kasten-io --set secrets.googleApiKey=$sa_key

# mv k10primer.yaml KK_K10_Primer.yaml
# chmod 777 KK_K10_Primer.yaml


##############################################################


echo ""
echo ""
echo "Next steps:"
echo ""
echo "   Run file 34 to provision the DataStax Cassandra Kubernetes Operator ..."
echo "   Run file 35 to provision the DataStax Astra Service Broker ..."
echo "   Run file 36 to provision the DataStax K8ssandra system ..."
echo ""
echo "   Just Kasten-"
echo "      watch kubectl get pods -n kasten-io"
echo "      kubectl --namespace kasten-io port-forward service/gateway 8080:8000"
echo ""
echo "      The Kasten dashboard will be available at:"
echo "         http://127.0.0.1:8080/k10/#/"

echo ""
echo ""







