
create table rhnISSSlaveOrgs (
	id number not null constraint rhn_isssorg_id_pk primary key,
	slave_id number not null constraint rhn_isssorg_sid_fk references rhnISSSlave(id) on delete cascade,
	org_id number not null constraint rhn_isssorg_oid_fk references web_customer(id) on delete cascade,
	created timestamp with local time zone default (current_timestamp) not null
);

create sequence rhn_issslave_org_seq;
