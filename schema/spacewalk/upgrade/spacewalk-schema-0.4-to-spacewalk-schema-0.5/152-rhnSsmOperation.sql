create table
rhnSsmOperation
(
    id          number
                constraint rhn_ssmop_id_nn not null
                constraint rhn_ssmop_id_pk primary key
                    using index tablespace [[4m_tbs]],
    user_id     number
                constraint rhn_ssmop_user_nn not null
                constraint rhn_ssmop_user_fk
                    references rhnUser(id)
                    on delete cascade,
    description varchar2(256)
                constraint rhn_ssmop_desc_nn not null,
    status      varchar2(32)
                constraint rhn_ssmop_st_nn not null,
    started     date
                constraint rhn_ssmop_strt_nn not null,
    modified    date default (sysdate)
                constraint rhn_ssmop_mod_nn not null
)
;


create sequence rhn_ss_op_seq;

create or replace trigger
rhn_ssmop_mod_trig
before insert or update on rhnSsmOperation
for each row
begin
    :new.modified := sysdate;
end;
/
show errors

create table
rhnSsmOperationServer
(
    operation_id   number
                   constraint rhn_ssmops_ssmop_fk
                       references rhnSsmOperation(id)
                       on delete cascade,
    server_id      number
                   constraint rhn_ssmops_ser_fk
                       references rhnServer(id)
                       on delete cascade
)
;

