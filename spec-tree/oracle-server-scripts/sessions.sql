-- http://www.dbasupport.com/oracle/scripts/Detailed/24.shtml
-- SID = Session identifier
-- SER = Session serial number
-- OSUER = Operating system username
-- OSPID = Operating system process identifier
-- STAT = Status of session (ACT=active INA=Inactive)
-- COM = Command number. Definition listed in table Audit_actions
-- SCHEMA = Oracle username
-- TYP = Type of process (USE=user BAC=background)
-- %HIT = Hit ratio in percent
-- CPU = CPU being used
-- BCHNG = Block changes
-- CCHNG = Consistent changes

select
    substr(s.sid,1,3) sid,
    substr(s.serial#,1,5) ser,
    substr(osuser,1,8) osuser,
    spid ospid,
    substr(status,1,3) stat,
    substr(command,1,3) com,
    substr(schemaname,1,10) schema,
    substr(type,1,3) typ,
    substr(decode( (consistent_gets+block_gets),
           0,'None',
           (100*(consistent_gets+block_gets-physical_reads) /
                (consistent_gets+block_gets)
	   )
	   ),1,4) "%HIT",
    value CPU,
    substr(block_changes,1,5) bchng,
    substr(consistent_changes,1,5) cchng
from
    v$process p,
    v$SESSTAT t,
    v$sess_io i ,
    v$session s
where
    i.sid=s.sid
and p.addr=paddr(+)
and s.sid=t.sid
and t.statistic#=12
/
