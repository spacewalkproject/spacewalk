create table
rhnActionVirtVcpu
(
    action_id   number  
                constraint rhn_avcpu_aid_nn not null
                constraint rhn_avcpu_aid_fk
                    references rhnAction(id)
                    on delete cascade,
    uuid        varchar(128)
                constraint rhn_avcpu_uuid_nn not null,
    vcpu      number
                constraint rhn_avcpu_vcpus_nn not null,
    created     date default(sysdate)
                constraint rhn_avcpu_creat_nn not null,
    modified    date default(sysdate)
                constraint rhn_avcpu_mod_nn not null
)
    storage ( freelists 16 )
    initrans 32;

create unique index rhn_avcpu_aid_uq
    on rhnActionVirtVcpu( action_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhnActionVirtVcpu add constraint rhn_avcpu_aid_pk
    primary key ( action_id );

create or replace trigger
rhn_avcpu_mod_trig
before insert or update on rhnActionVirtVcpu
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
