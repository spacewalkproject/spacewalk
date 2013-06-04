create table rhnIssMaster (
    id number not null constraint rhn_iss_master_id_pk primary key,
    label varchar2(256) not null constraint rhn_iss_master_label_uq unique,
    created timestamp with local time zone default (current_timestamp) not null
);

create sequence rhn_issmaster_seq;
