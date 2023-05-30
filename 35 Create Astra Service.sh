#!/bin/bash


. "./20 Defaults.sh"


##############################################################


echo ""
echo ""
echo "Calling 'helm', svcat', and 'kubectl' to provision an Astra service binding ..."
echo ""
echo "  .  The namespace ${MY_NS_USER2} will be dropped, and recreated,"
echo "     and all Astra service binding assets will be placed there."
echo "  .  Part of this program allocates a database service instance on"
echo "     DataStax Astra, so this whole program takes a bit to complete."
echo ""
echo "  .  There are alot of (undo), then (do) style commands below, fyi."
echo "     If you are running this command for the first time, you will"
echo "     see a bunch of errors you can ignore related to the undos."
echo ""
echo "  .  We don't do any cleanup on the Astra side. We do call to create"
echo "     a Cassandra keyspace on the Astra side between iterations. If that"
echo "     keyspace and database already exist .. .."
echo ""
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
echo ""
sleep 10


echo "Step 01-n: Delete target namespace .."
echo "----------------------------------------"
kubectl delete namespace ${MY_NS_USER2} --force 2> /dev/null
echo ""
echo "Step 01-n: Create target namespace .."
echo "----------------------------------------"
kubectl create namespace ${MY_NS_USER2}
echo ""

# echo "Step 01-n: Remove Helm repo .."
# echo "----------------------------------------"
# helm repo remove service-catalog
# echo ""
echo "Step 01-n: Add Helm repo .."
echo "----------------------------------------"
helm repo add service-catalog https://kubernetes-sigs.github.io/service-catalog
echo ""
echo "Step 01-n: Helm repo update .."
echo "----------------------------------------"
helm repo update
echo ""

# echo "Step 01-n: Helm entry delete .."
# echo "----------------------------------------"
# helm delete catalog service-catalog/catalog --namespace ${MY_NS_USER2}
# echo ""
echo "Step 01-n: Helm entry install .."
echo "----------------------------------------"
helm install catalog service-catalog/catalog --namespace ${MY_NS_USER2}
echo ""
sleep 20


##############################################################


echo ""
echo ""
echo "Note: Here we are using hard coded 'credentials' against our DataStax Astra"
echo "      account, under the organization titled, 'my_org'."
echo ""
echo "      So, if program execution fails here you need to edit 'l_creds' in file 20."
echo ""
echo ""
   #
# echo "Step 02-n: Kubectl delete secret .."
# echo "----------------------------------------"
# kubectl delete secret astra-creds -n ${MY_NS_USER2}
# echo ""
echo "Step 02-n: Kubectl create secret .."
echo "----------------------------------------"
kubectl create secret generic astra-creds --from-literal=username=unused --from-literal=password=`echo ${l_creds} | base64 -w 0` -n ${MY_NS_USER2}
echo ""
sleep 20


##############################################################


# echo "Step 03-n: Deregister the Astra broker entry .."
# echo "----------------------------------------"
# svcat deregister astra -n ${MY_NS_USER2}
# echo ""

echo "Step 03-n: Register the Astra broker entry .."
echo "----------------------------------------"
svcat register astra --url https://broker.astra.datastax.com/ --basic-secret astra-creds -n ${MY_NS_USER2} 2> /dev/null
echo ""

echo ""
echo "Looping until we see that our requested Kubernetes broker resource is in a 'Ready' state."
echo ""

l_cntr=0
   #
while :
   do
   l_if_ready=`svcat get brokers -n ${MY_NS_USER2} 2> /dev/null | \
      grep 'astra' | grep 'https://broker.astra.datastax.com/' | \
      grep 'Ready' | wc -l`
         #
   [ ${l_if_ready} -lt 1 ] && {
      l_cntr=$((l_cntr+1))
      echo "   Waiting for Broker 'Ready' state .. (${l_cntr})"
         #
      sleep 20
   } || {
      break
   }
   done
echo "   Broker 'Ready'."
echo ""


##############################################################


echo ""
echo "Step 04: Create an Astra Service Instance .."
echo "----------------------------------------"

svcat -n ${MY_NS_USER2} provision ${MY_SVC_DB} --class astra-database --plan developer --params-json "{
   \"cloud_provider\": \"${MY_CLOUD_VENDOR}\",
   \"region\": \"${MY_ASTRA_REGION}\",
   \"capacity_units\": 1,
   \"keyspace\": \"${MY_ASTRA_KEYSPACE}\"
   }"

echo ""
echo "Looping until we see that our requested Astra server instance is in a 'Ready' state."
echo ""

l_cntr=0
   #
while :
   do
   l_if_ready=`svcat get instances -n ${MY_NS_USER2} 2> /dev/null | \
      grep "${MY_SVC_DB}" | grep "${MY_NS_USER2}" | grep 'Ready' | wc -l`
         #
   [ ${l_if_ready} -lt 1 ] && {
      l_cntr=$((l_cntr+1))
      echo "   Waiting for Instance 'Ready' state .. (${l_cntr})"
         #
      sleep 20
   } || {
      break
   }
   done
echo "   Instance 'Ready'."
echo ""


##############################################################


echo ""
echo "Step 05: Create the 'binding' in our local Kubernetes, to this remote Astra server instance .."
echo "----------------------------------------"

svcat -n ${MY_NS_USER2} bind ${MY_SVC_DB}

echo ""
echo "Looping until we see that our binding is in a 'Ready' state."
echo ""

l_cntr=0
   #
while :
   do
   l_if_ready=`svcat get bindings -n ${MY_NS_USER2} 2> /dev/null | \
      grep "${MY_SVC_DB}" | grep "${MY_NS_USER2}" | grep 'Ready' | wc -l`
         #
   [ ${l_if_ready} -lt 1 ] && {
      l_cntr=$((l_cntr+1))
      echo "   Waiting for Binding 'Ready' state .. (${l_cntr})"
         #
      sleep 20
   } || {
      break
   }
   done
echo "   Binding 'Ready'."
echo ""


##############################################################


echo ""
echo "Step 06: Generating the 'secure bundle Zip file' for clients .."
echo "----------------------------------------"

kubectl -n ${MY_NS_USER2} get secret ${MY_SVC_DB} -o json | \
   jq -r ".data.encoded_external_bundle" | base64 -d | \
   base64 -d > secure-bundle.zip
      #
l_USER=`kubectl -n ${MY_NS_USER2} get secret ${MY_SVC_DB} -o json |
   jq -r ".data.username" | base64 -d `       
l_PASS=`kubectl -n ${MY_NS_USER2} get secret ${MY_SVC_DB} -o json |
   jq -r ".data.password" | base64 -d `


echo ""
echo ""
echo "Next steps:"
echo ""
echo "   cqlsh -u ${l_USER} -p ${l_PASS} -b secure-bundle.zip"
echo ""
echo "      ** Sometimes the above command fails if you run it too soon."
echo ""
echo ""
echo "   In a client program, you will need code similar to,"
echo ""
echo "      const client = new Client({"
echo "        cloud: { secureConnectBundle: './path/to/secure-bundle.zip' },"
echo "        credentials: { username: 'user_name', password: 'p@ssword1' }"
echo "      });"
echo ""
echo ""





