create table
rhnActionVirtSetMemory
(
    action_id   number  
                constraint rhn_avsm_aid_nn not null
                constraint rhn_avsm_aid_fk
                    references rhnAction(id)
                    on delete cascade,
    uuid        varchar(128)
                constraint rhn_avsm_uuid_nn not null,
    memory      number
                constraint rhn_avsm_mem_nn not null,
    created     date default(sysdate)
                constraint rhn_avsm_creat_nn not null,
    modified    date default(sysdate)
                constraint rhn_avsm_mod_nn not null
)
    storage ( freelists 16 )
    initrans 32;

create unique index rhn_avsm_aid_uq
    on rhnActionVirtSetMemory( action_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhnActionVirtSetMemory add constraint rhn_avsm_aid_pk
    primary key ( action_id );

create or replace trigger
rhn_avsm_mod_trig
before insert or update on rhnActionVirtSetMemory
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
