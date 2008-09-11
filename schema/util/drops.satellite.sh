#!/bin/bash

usage() {
    echo "Usage: $0 <connection_string>"
    echo
    echo "  <connection_string> ::== <username>/<password>@<instance>"
    echo
    exit 1
}

CONNSTRING=$1
[ -z "$CONNSTRING" ] && usage

DROPSFILE=.drops-$$.sql

drop_all() {
    sqlplus -S ${CONNSTRING} << EOF
set feedback on
set heading off
select 'drop type ' || object_name || ' force;' 
from user_objects
where object_type = 'TYPE'
union
select 'drop '|| object_type ||' '|| object_name || ';' 
from user_objects
where object_type not in ('TABLE', 'INDEX', 'TRIGGER', 'TYPE', 'TYPE BODY', 'LOB')
union
select 'drop table ' || object_name || ' cascade constraints;' 
from user_objects
where object_type = 'TABLE'
and object_name not like '%$%';
EOF
}

while [ 1 ]; do
    drop_all > $DROPSFILE
    
    grep "no rows selected" $DROPSFILE > /dev/null 2>&1 && break

    sqlplus -S ${CONNSTRING} @$DROPSFILE < /dev/null
done
echo Done
rm -f $DROPSFILE
