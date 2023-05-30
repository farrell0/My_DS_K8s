#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'gcloud' to delete K8s cluster ..."
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


gcloud container clusters delete -q ${MY_CLUSTER} --zone ${GKE_ZONE} --project ${GKE_PROJECT}
echo ""
# gsutil -m rm -r gs://${MY_BUCKET}


#  This is a bit of a hack-
#
#     .  On subsequent loops/use of this toolkit, leftover entries
#        under .ssh would interfere with logging into new clusters.
#
#        I run these on an air-gapped VM, so it's okay for me to 
#        delete under here.
#
rm -f ${HOME}/.ssh/*
echo "StrictHostKeyChecking no" > ${HOME}/.ssh/config


echo ""
echo ""


