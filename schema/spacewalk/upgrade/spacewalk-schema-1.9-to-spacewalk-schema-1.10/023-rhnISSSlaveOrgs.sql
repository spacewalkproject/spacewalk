create table rhnISSSlaveOrgs (
    slave_id number not null constraint rhn_isssorg_sid_fk references rhnISSSlave(id) on delete cascade,
    org_id number not null constraint rhn_isssorg_oid_fk references web_customer(id) on delete cascade,
    created timestamp with local time zone default (current_timestamp) not null
);
