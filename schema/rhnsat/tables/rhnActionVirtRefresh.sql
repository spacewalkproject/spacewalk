create table
rhnActionVirtRefresh
(
    action_id   number  
                constraint rhn_avrefresh_aid_nn not null
                constraint rhn_avrefresh_aid_fk
                    references rhnAction(id)
                    on delete cascade,
    created     date default(sysdate)
                constraint rhn_avrefresh_creat_nn not null,
    modified    date default(sysdate)
                constraint rhn_avrefresh_mod_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

create unique index rhn_avrefresh_aid_uq
    on rhnActionVirtRefresh( action_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhnActionVirtRefresh add constraint rhn_avrefresh_aid_pk
    primary key ( action_id );

create or replace trigger
rhn_avrefresh_mod_trig
before insert or update on rhnActionVirtRefresh
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
