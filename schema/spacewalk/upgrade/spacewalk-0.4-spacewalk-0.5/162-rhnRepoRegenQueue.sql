create table 
rhnRepoRegenQueue
( 
       id                 number 
                          constraint rhn_reporegenq_id_nn not null enable 
                          constraint rhn_reporegenq_id_pk primary key,
       channel_label      varchar2(128)
                          constraint rhn_reporegenq_chan_label_nn not null enable,
       client             varchar2(128),
       reason             varchar2(128),
       force              char(1),
       bypass_filters     char(1),
       next_actionN       date default (sysdate),
       created            date default (sysdate) 
                          constraint rhn_reporegenq_created_nn not null enable,
       modified           date default (sysdate) 
                          constraint rhn_reporegenq_modified_nn not null enable
  );

create sequence rhn_repo_regen_queue_id_seq start with 101;

create or replace trigger rhn_repo_regen_queue_mod_trig
before insert or update on rhnRepoRegenQueue
for each row
begin
    :new.modified := sysdate;
end;
/

