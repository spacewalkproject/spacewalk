REM @/home/dfaraldo/NOCpulse/CVS_PKG/sputnik/SputLite/drop-sputlite-tables

PROMPT Dropping command execs table (COMMAND_QUEUE_EXECS)
DROP TABLE project04.command_queue_execs;

PROMPT Dropping command instances table (COMMAND_QUEUE_INSTANCES)
DROP TABLE project04.command_queue_instances;

PROMPT Dropping commands table (COMMAND_QUEUE_COMMANDS)
DROP TABLE project04.command_queue_commands;

PROMPT Dropping commands recid sequence
DROP SEQUENCE COMMAND_Q_COMMAND_RECID;

PROMPT Dropping command instances recid sequence
DROP SEQUENCE COMMAND_Q_INSTANCE_RECID;


