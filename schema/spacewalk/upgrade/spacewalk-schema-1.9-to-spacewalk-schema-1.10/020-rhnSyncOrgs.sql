create table rhnSyncOrgs (
    id number not null constraint rhn_syncorgs_id_pk primary key,
    catalogue_id number not null
        constraint rhn_syncorgs_cid_fk references rhnSyncOrgCatalogue(id) on delete cascade,
    source_org_id number not null,
    source_org_name varchar2(512) not null,
    target_id number
        constraint rhn_syncorgs_tid_fk references web_customer(id),
    created timestamp with local time zone default (current_timestamp) not null
);

create sequence rhn_syncorgs_seq;
