create table rhnISSSlave (
    id number not null constraint rhn_isss_id_pk primary key,
    slave varchar2(512) not null constraint rhn_isss_name_uq unique,
    enabled char(1) default 'Y' not null
        constraint rhn_isss_enabled_yn check (enabled in ( 'Y', 'N' )),
    allow_all_orgs char(1) not null default 'Y',
        constraint rhn_isss_allorgs_yn check (allow_all_orgs in ( 'Y', 'N' )),
    created timestamp with local time zone default (current_timestamp) not null,
    modified timestamp with local time zone default (current_timestamp) not null
);

create sequence rhn_issslave_seq;
