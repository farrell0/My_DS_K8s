#!/bin/bash


. ./21_DefaultsOnGenericPod.sh


##############################################################


l_host=`uname -a | awk '{print $2}'`
[ ${l_host} == "generic-pod" ] || {
   echo ""
   echo ""
   echo "ERROR: This program should only be run on the 'generic pod'."
   echo ""
   echo ""
   exit 1
 }


##############################################################


echo ""
echo ""
echo "Run cassandra-stress with prompts ..."
echo ""
echo "**  You have 10 seconds to cancel before proceeding."
echo ""
sleep 10


echo ""
echo -n "Should I read or write ? [r|w] "
read l_rw
   #
[ -z ${l_rw} ] && l_rw=w
[ ${l_rw} == "r" ] || l_rw="w"


echo ""
echo ""
echo -n "How many rows should I operate on ? [0..N] " 
read l_cnt

echo ""
echo ""


##############################################################


cd /opt
mkdir -p /opt/logs
   #
[ ${l_rw} == "r" ] && {

   cassandra-stress read  n=${l_cnt} cl=ONE -mode native cql3 user=${CASS_USER} password=${CASS_PASS} -node ${IP_LIST} -rate threads=800 | tee /opt/logs/log.${$}

} || {

   cassandra-stress write n=${l_cnt} cl=ONE -mode native cql3 user=${CASS_USER} password=${CASS_PASS} -node ${IP_LIST} -rate threads=800 | tee /opt/logs/log.${$}

}

echo ""
echo ""
echo "Output log file was: /opt/logs/log."${$}
echo ""
echo ""








