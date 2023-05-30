#!/bin/bash


#
#  This file is sourced from most programs in this folder;
#  variables used throughout
#


alias kc=kubectl

#  Generally, this block used for Kubernetes and C* Operator work
#
GKE_PROJECT=gke-launcher-dev
# GKE_ZONE=us-central1-a
GKE_ZONE=us-central1-f
   #
MY_CLUSTER=farrell-cluster

MY_NS_OPERATOR=ns-cass-operator
   #
MY_NS_CCLUSTER1=ns-cass-sys1
MY_NS_CCLUSTER2=ns-cass-sys2
   #
MY_NS_USER1=ns-user1
MY_NS_USER2=ns-user2

#  Genernally, this block used for work with Velero
#
MY_BUCKET=farrell-gcs-bucket


#  Generally, this block used for creating a service broker to
#  an Astra hosted C* database server instance
#
#  Below-
#     From our DataStax Astra acct, the 'Service Acct' credentials
#     under the 'my_org' organization.   (Yup, blatant hard coding.)
#
l_creds='{"clientId":"2c4a665b-43XXXXXXXXXXXXXXXX8ba18db19","clientName":"my_org","clientSecret":"7ff07609-c4XXXXXXXXXXXXXd13941"}'
   #
MY_SVC_DB=my-svc-db
MY_CLOUD_VENDOR=GCP
MY_ASTRA_KEYSPACE=my_keyspace
MY_ASTRA_REGION=us-east1


#  Generally, this block used for K8ssandra
#
MY_K8S_NS=ns-k8s
MY_K8S_C_NODE=k8ssandra-dc1-default-sts-0
MY_K8S_STARGATE_PODS=k8ssandra-dc1-stargate
MY_C_SERVICE=k8ssandra-dc1-stargate-service


