REM @/home/dfaraldo/NOCpulse/CVS_PKG/sputnik/SputLite/create-sputlite-tables

PROMPT Creating commands table (COMMAND_QUEUE_COMMANDS)
CREATE TABLE project04.command_queue_commands (
  recid                 number(12) PRIMARY KEY,
  description           varchar2(40),
  notes                 varchar2(2000),
  command_line          varchar2(2000),
  permanent             char(1),
  restartable           char(1),
  effective_user        varchar2(40),
  effective_group       varchar2(40),
  last_update_user      varchar2(40),
  last_update_date      date
);

REM description, command_line, permanent, restartable,
REM effective_user, and effective_group should be NOT NULL


PROMPT Creating command instances table (COMMAND_QUEUE_INSTANCES)
CREATE TABLE project04.command_queue_instances (
  recid                 number(12) PRIMARY KEY,
  command_id            number(12),
  notes                 varchar2(2000),
  date_submitted        date,
  expiration_date       date,
  notify_email          varchar2(50),
  timeout               number(5),
  last_update_user      varchar2(40),
  last_update_date      date
);

REM command_id, date_submitted, and expiration_date should be NOT NULL



PROMPT Creating command executions table (COMMAND_QUEUE_EXECS)
CREATE TABLE project04.command_queue_execs (
  instance_id           number(12),
  netsaint_id           number(12),
  date_accepted         date,
  date_executed         date,
  exit_status           number(5),
  execution_time        number(10,6),
  stdout                varchar2(2000),
  stderr                varchar2(2000),
  last_update_user      varchar2(40),
  last_update_date      date
);


PROMPT Creating instances -> commands foreign key
ALTER TABLE project04.command_queue_instances
  ADD CONSTRAINT COMMAND_Q_INSTANCE_COMMAND_FK
    FOREIGN KEY (command_id) REFERENCES command_queue_commands(recid);

PROMPT Creating command exec -> instance instances foreign key
ALTER TABLE project04.command_queue_execs
  ADD CONSTRAINT COMMAND_Q_EXECS_INSTANCE_FK
    FOREIGN KEY (instance_id) REFERENCES command_queue_instances(recid);

PROMPT Creating command exec -> netsaint foreign key
ALTER TABLE project04.command_queue_execs
  ADD CONSTRAINT COMMAND_Q_EXECS_NETSAINT_FK
    FOREIGN KEY (netsaint_id) REFERENCES netsaint(recid);

PROMPT Creating commands recid sequence
CREATE SEQUENCE COMMAND_Q_COMMAND_RECID START WITH 1000;

PROMPT Creating instances table recid sequence
CREATE SEQUENCE COMMAND_Q_INSTANCE_RECID;
