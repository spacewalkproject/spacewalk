set ORATAB=/etc/oratab

if ( -r "$ORATAB" ) then
    set ORACLE_HOME=`awk -F: '/^\*:/ {print $2}' $ORATAB`
endif
if ( -d "$ORACLE_HOME" ) then
    setenv ORACLE_HOME "$ORACLE_HOME"
    setenv PATH ${ORACLE_HOME}/bin:${PATH}
endif

