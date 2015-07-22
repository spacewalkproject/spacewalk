create table rhnIssMaster (
    id number not null constraint rhn_iss_master_id_pk primary key,
    label varchar2(256) not null constraint rhn_iss_master_label_uq unique,
    created timestamp with local time zone default (current_timestamp) not null,
    is_current_master char(1) default 'N' not null constraint rhn_issm_master_yn check (is_current_master in ('Y', 'N')),
    ca_cert varchar2(1024)
);

create sequence rhn_issmaster_seq;
