1) Create instance:

    <INSTANCE_ID> = COMMAND_Q_INSTANCE_RECID_SEQ.NEXTVAL;

    INSERT INTO COMMAND_QUEUE_INSTANCES (
	   recid, 
	   command_id, 
	   expiration_date, 
	   timeout,
	   date_submitted, 
	   last_update_user,
	   last_update_date)
    VALUES (?,
	    ?, 
	    sysdate + (<EXPIRE MINUTES>/60*24), 
	    ?, 
	    sysdate, 
	    ?,
	    sysdate);

  BIND VARS: (<INSTANCE_ID>, 1, <TIMEOUT SECONDS>, <CONTACT NAME>)


2) Foreach $sat, create exec:

    INSERT INTO COMMAND_QUEUE_EXECS (
	   instance_id,
	   netsaint_id,
	   last_update_user,
	   last_update_date)
    VALUES (?, ?, <CONTACT NAME>, sysdate);

  BIND VARS: (<INSTANCE ID>, $sat)



3) To check the status:

     SELECT   count(*)
     FROM     command_queue_execs exec, command_queue_instances inst
     WHERE    inst.command_id = 1
     AND      exec.instance_id = inst.recid
     AND      netsaint_id = ?
     AND      date_executed is null
     AND      sysdate < expiration_date;

As long as this query returns a row, the install is PENDING.  Once
it returns 0 rows, either 1) the command has been executed, or 
2) the instance expired.


     SELECT   inst.date_submitted, exec.date_accepted, exec.date_executed, 
              exec.exit_status, exec.execution_time, exec.stdout, exec.stderr
     FROM     command_queue_execs exec, command_queue_instances inst
     WHERE    inst.command_id = 1
     AND      exec.instance_id = inst.recid
     AND      netsaint_id = ?
     AND      rownum = 1
     ORDER BY date_submitted DESC;

  BIND VARS: ($sat)

This will give you a record for the last config push to the identified
satellite.

