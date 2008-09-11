create table
rhnActionVirtResume
(
    action_id   number  
                constraint rhn_avresume_aid_nn not null
                constraint rhn_avresume_aid_fk
                    references rhnAction( id )
                    on delete cascade,
    uuid        varchar(128)
                constraint rhn_avresume_uuid_nn not null,
    created     date default(sysdate)
                constraint rhn_avresume_creat_nn not null,
    modified    date default(sysdate)
                constraint rhn_avresume_mod_nn not null
)
    storage ( freelists 16 )
    initrans 32;

create unique index rhn_avresume_aid_uq
    on rhnActionVirtResume( action_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhnActionVirtResume add constraint rhn_avresume_aid_pk
    primary key ( action_id );

create or replace trigger
rhn_avresume_mod_trig
before insert or update on rhnActionVirtResume
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
