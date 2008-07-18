create table
rhnActionVirtReboot
(
    action_id   number  
                constraint rhn_avreboot_aid_nn not null 
                constraint rhn_avreboot_aid_fk
                    references rhnAction(id)
                    on delete cascade,
    uuid        varchar(128)
                constraint rhn_avreboot_uuid_nn not null,
    created     date default(sysdate)
                constraint rhn_avreboot_creat_nn not null,
    modified    date default(sysdate)
                constraint rhn_avreboot_mod_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

create unique index rhn_avreboot_aid_uq
    on rhnActionVirtReboot( action_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhnActionVirtReboot add constraint rhn_avreboot_aid_pk
    primary key ( action_id );

create or replace trigger
rhn_avreboot_mod_trig
before insert or update on rhnActionVirtReboot
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
