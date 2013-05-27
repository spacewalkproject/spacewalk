create table rhnSyncOrgCatalogue (
    id number not null constraint rhn_sync_org_cat_id_pk primary key,
    label varchar2(256) not null constraint rhn_sync_org_cat_label_uq unique,
    created timestamp with local time zone default (current_timestamp) not null
);

create sequence rhn_syncorgcatalogue_seq;
