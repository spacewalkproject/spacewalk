create table
rhnActionVirtStart
(
    action_id   number  
                constraint rhn_avstart_aid_nn not null,
    uuid        varchar(128)
                constraint rhn_avstart_uuid_nn not null,
    created     date default(sysdate)
                constraint rhn_avstart_creat_nn not null,
    modified    date default(sysdate)
                constraint rhn_avstart_mod_nn not null
)
    storage ( freelists 16 )
    initrans 32;

create unique index rhn_avstart_aid_uq
    on rhnActionVirtStart( action_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhnActionVirtStart add constraint rhn_avstart_aid_pk
    primary key ( action_id );

create or replace trigger
rhn_avstart_mod_trig
before insert or update on rhnActionVirtStart
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
