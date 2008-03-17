OracleVersionShort=$(basename $(cd $(dirname $0) && pwd))
Oracle=/opt/apps/oracle
OracleHome=$Oracle/web/product/$OracleVersionShort/db_1

export ORACLE_INIT=$Oracle/admin/$OracleVersionShort/$ORACLE_SID/init.ora
export ORACLE_HOME=$OracleHome
echo "Using ORACLE_HOME=$ORACLE_HOME"
