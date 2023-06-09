#!/usr/bin/env bash

export JAVA8_HOME=/usr/local/java8
export JAVA_HOME=${JAVA8_HOME}

CONTINUE_MOD=$1

DATE_STRING=`date +%Y-%m-%d`
BUILD_PARAMETERS=""

if [[ "$OSTYPE" == "darwin"* ]]; then
  BUILD_PARAMETERS="-Dsnappy.prefix=x \
                    -Dbundle.snappy=true \
                    -Dsnappy.lib=/usr/lib64 \
                    -Pdist \
                    -Pnative \
                    -Psrc \
                    -Pyarn-ui \
                    -Dtar \
                    -Dzookeeper.version=3.6.4 \
                    -Dleveldbjni.group=org.fusesource.leveldbjni \
                    -DskipTests \
                    -DskipITs \
                    clean install"
else
  BUILD_PARAMETERS="-Pdist \
                    -Pnative \
                    -Psrc \
                    -Pyarn-ui \
                    -Dtar \
                    -DskipTests \
                    -DskipITs \
                    -Dzookeeper.version=3.6.4 \
                    -Dleveldbjni.group=org.fusesource.leveldbjni \
                    -Dsnappy.prefix=x \
                    -Dbundle.snappy=true \
                    -Dsnappy.lib=/usr/lib64 \
                    -Dbundle.zstd=true \
                    -Dzstd.lib=/usr/local/lib \
                    clean install"
fi

mkdir -p my-build-logs || true
if [ "x${CONTINUE_MOD}" == "x" ]; then
  echo "building from 1st module"
  echo "-----------------------------start of new building----------------------------------------" | tee -a my-build-logs/build-${DATE_STRING}.log
  mvn -s ~/.m2/settings.xml -gs ~/.m2/settings.xml ${BUILD_PARAMETERS} 2>&1 | tee -a my-build-logs/build-${DATE_STRING}.log
  source /opt/rh/devtoolset-10/enable
  mvn -s ~/.m2/settings.xml -gs ~/.m2/settings.xml ${BUILD_PARAMETERS} -rf :hadoop-yarn-server-nodemanager 2>&1 | tee -a my-build-logs/build-${DATE_STRING}.log
  exit
else
  echo "building from module: ${CONTINUE_MOD}"
  echo "------------------------continue building from ${CONTINUE_MOD}---------------------------------" | tee -a my-build-logs/build-${DATE_STRING}.log
  source /opt/rh/devtoolset-10/enable
  mvn -s ~/.m2/settings.xml -gs ~/.m2/settings.xml ${BUILD_PARAMETERS} -rf :${CONTINUE_MOD} 2>&1 | tee -a my-build-logs/build-${DATE_STRING}.log
  exit
fi
