create table
rhnActionVirtSuspend
(
    action_id   number  
                constraint rhn_avsuspend_aid_nn not null
                constraint rhn_avsuspend_aid_fk
                    references rhnAction(id)
                    on delete cascade,
    uuid        varchar(128)
                constraint rhn_avsuspend_uuid_nn not null,
    created     date default(sysdate)
                constraint rhn_avsuspend_creat_nn not null,
    modified    date default(sysdate)
                constraint rhn_avsuspend_mod_nn not null
)
    storage ( freelists 16 )
    initrans 32;

create unique index rhn_avsuspend_aid_uq
    on rhnActionVirtSuspend( action_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhnActionVirtSuspend add constraint rhn_avsuspend_aid_pk
    primary key ( action_id );

create or replace trigger
rhn_avsuspend_mod_trig
before insert or update on rhnActionVirtSuspend
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
