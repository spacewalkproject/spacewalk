create table rhnIssMasterOrgs (
    id number not null constraint rhn_issmasterorgs_id_pk primary key,
    master_id number not null
        constraint rhn_issmasterorgs_cid_fk references rhnIssMaster(id) on delete cascade,
    master_org_id number not null,
    master_org_name varchar2(512) not null,
    local_org_id number
        constraint rhn_issmasterorgs_lid_fk references web_customer(id),
    created timestamp with local time zone default (current_timestamp) not null
);

create sequence rhn_issmasterorgs_seq;
