#!/bin/bash

echo "******************************************************************************"
echo "Check first run." `date`
echo "******************************************************************************"

FIRST_RUN="false"
if [ ! -f /run/FIRST_RUN_FLAG ]; then
  echo "First run."
  FIRST_RUN="true"
  touch /run/FIRST_RUN_FLAG
else
  echo "Not first run."
fi

echo "******************************************************************************"
echo "Handle shutdowns." `date`
echo "docker stop --time=30 {container}" `date`
echo "******************************************************************************"
function shutdown_container {
  ${CATALINA_HOME}/bin/shutdown.sh
}

trap shutdown_container SIGINT
trap shutdown_container SIGTERM
trap shutdown_container SIGKILL

function install_apex(){
  cd /opt/apex
  
  sqlplus ${DBA_USER}/${DBA_PASSWORD}@${DB_HOSTNAME}:${DB_PORT}/${DB_SERVICE} as sysdba << EOF
    @apxsilentins.sql ${APEX_TABLESPACE} ${APEX_TABLESPACE} ${TEMP_TABLESPACE} /i/ ${APEX_PUBLIC_PASSWORD} ${APEX_LISTENER_PASSWORD} ${APEX_REST_PASSWORD} ${APEX_ADMIN_PASSWORD}
    exit;
EOF

  mkdir $CATALINA_BASE/webapps/i/
  cp -R /opt/apex/images/* $CATALINA_BASE/webapps/i/
}

function install_ords()
{
  cd /opt/ords

  sed -i -e "/^db\.hostname=/s/=.*/=${DB_HOSTNAME}/" /opt/ords/params/ords_params.properties &&\
  sed -i -e "/^db\.port=/s/=.*/=${DB_PORT}/" /opt/ords/params/ords_params.properties &&\
  sed -i -e "/^db\.servicename=/s/=.*/=${DB_SERVICE}/" /opt/ords/params/ords_params.properties &&\
  sed -i -e "/^sys\.user=/s/=.*/=${DBA_USER}/" /opt/ords/params/ords_params.properties &&\
  sed -i -e "/^sys\.password=/s/=.*/=${DBA_PASSWORD}/" /opt/ords/params/ords_params.properties

  java -jar ords.war configdir /opt/ords/conf
  java -jar ords.war install --silent
  cp ords.war ${CATALINA_BASE}/webapps/
}

if [ "${FIRST_RUN}" == "true" ]; then
  echo "******************************************************************************"
  echo "Install apex." `date`
  echo "******************************************************************************"

  install_apex

  echo "******************************************************************************"
  echo "Install ords." `date`
  echo "******************************************************************************"

  install_ords
fi

echo "******************************************************************************"
echo "Start Tomcat." `date`
echo "******************************************************************************"
${CATALINA_HOME}/bin/startup.sh

echo "******************************************************************************"
echo "Tail the Catalina as log." `date`
echo "******************************************************************************"

tail -f ${CATALINA_BASE}/logs/catalina.out &
bgPID=$!
wait $bgPID
