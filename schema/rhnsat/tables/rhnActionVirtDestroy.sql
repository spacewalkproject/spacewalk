create table
rhnActionVirtDestroy
(
    action_id   number  
                constraint rhn_avd_aid_nn not null
                constraint rhn_avd_aid_fk
                    references rhnAction(id)
                    on delete cascade,
    uuid        varchar(128)
                constraint rhn_avd_uuid_nn not null,
    created     date default(sysdate)
                constraint rhn_avd_creat_nn not null,
    modified    date default(sysdate)
                constraint rhn_avd_mod_nn not null
)
    storage ( freelists 16 )
    initrans 32;

create unique index rhn_avd_aid_uq
    on rhnActionVirtDestroy( action_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhnActionVirtDestroy add constraint rhn_avd_aid_pk
    primary key ( action_id );

create or replace trigger
rhn_avd_mod_trig
before insert or update on rhnActionVirtDestroy
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
