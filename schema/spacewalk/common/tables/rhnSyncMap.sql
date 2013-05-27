create table rhnSyncMap (
    source_id number not null
        constraint rhn_sync_orgs_sid_fk references rhnSyncOrgs(id) on delete cascade,
    target_id number not null
        constraint web_customer_tid_fk references web_customer(id) on delete cascade,
    created timestamp with local time zone default (current_timestamp) not null
);
