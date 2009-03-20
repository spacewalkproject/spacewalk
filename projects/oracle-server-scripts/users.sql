set linesize 120
column sid format 9999
column "User" format A10
column "Schema" format A10
column "From" format A40
column "Logon Time" format A20
column "Command" format A20

select sid,
    vs.username "User",
    vs.status "Status",
    vs.schemaname "Schema",
    vs.osuser || '@' || vs.machine "From",
    to_char(vs.logon_time, 'Mon DD YYYY HH:MI:SS') "Logon Time",
    aa.name "Command"
from
    v$session vs,
    audit_actions aa
where
     vs.command = aa.action
 and username is not null
/
