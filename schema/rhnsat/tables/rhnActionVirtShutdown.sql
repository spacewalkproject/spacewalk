create table
rhnActionVirtShutdown
(
    action_id   number  
                constraint rhn_avshutdown_aid_nn not null
                constraint rhn_avshutdown_aid_fk 
                    references rhnAction(id)
                    on delete cascade,
    uuid        varchar(128)
                constraint rhn_avshutdown_uuid_nn not null,
    created     date default(sysdate)
                constraint rhn_avshutdown_creat_nn not null,
    modified    date default(sysdate)
                constraint rhn_avshutdown_mod_nn not null
)
    storage ( freelists 16 )
    initrans 32;

create unique index rhn_avshutdown_aid_uq
    on rhnActionVirtShutdown( action_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhnActionVirtShutdown add constraint rhn_avshutdown_aid_pk
    primary key ( action_id );

create or replace trigger
rhn_avshutdown_mod_trig
before insert or update on rhnActionVirtShutdown
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
