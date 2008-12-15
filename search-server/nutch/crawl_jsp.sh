#!/bin/bash


if [ "${JAVA_HOME}" = "" ]; then
    export JAVA_HOME=/usr/lib/jvm/java
    echo "Setting JAVA_HOME to: ${JAVA_HOME}"
fi

export NUTCH_HOME=/usr/share/nutch
export NUTCH_CONF_DIR=`pwd`/crawl_jsp/conf
export NUTCH_OPTS=-Djava.util.logging.config.file="${NUTCH_CONF}/logging.properties"
export NUTCH_LOG_DIR=`pwd`/logs
export NUTCH_LOG_FILE=$0.log
export OUTPUT_DIR=`pwd`/data/crawl_jsp

echo "NUTCH_HOME = ${NUTCH_HOME}"
echo "NUTCH_CONF_DIR = ${NUTCH_CONF_DIR}"
echo "NUTCH_OPTS = ${NUTCH_OPTS}"
echo "NUTCH_LOG_DIR = ${NUTCH_LOG_DIR}"
echo "NUTCH_LOG_FILE = ${NUTCH_LOG_FILE}"
echo "OUTPUT_DIR = ${OUTPUT_DIR}"

if [ ! -d ${NUTCH_LOG_DIR} ]; then
    echo "Creating log directory ${NUTCH_LOG_DIR}"
    mkdir ${NUTCH_LOG_DIR}
fi


if [ ! -d ${OUTPUT_DIR} ]; then
    echo "Creating output directory ${OUTPUT_DIR}"
    mkdir -p ${OUTPUT_DIR}
fi
#Need to adjust nutch RPM so it's scripts under bin are executable by all

${NUTCH_HOME}/bin/nutch crawl ${NUTCH_CONF_DIR}/../urls -dir ${OUTPUT_DIR} -depth 10 -threads 50
