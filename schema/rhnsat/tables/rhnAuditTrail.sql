-- $Id$
--
-- one element of an audit trail
--
-- EXCLUDE: all

create table
rhnAuditTrail
(
	id		number
			constraint rhn_audittrail_id_nn not null,
	org_id		number
			constraint rhn_audittrail_oid_nn not null
			constraint rhn_audittrail_oid_fk
				references web_customer(id),
	user_id		number
			constraint rhn_audittrail_uid_fk 
				references web_contact(id),
	summary		varchar2(128)
			constraint rhn_audittrail_summary_nn not null,
	details		varchar2(4000),
	created		date default(sysdate)
			constraint rhn_audittrail_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_audittrail_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_audittrail_id_seq;

create index rhn_atrail_id_oid_uid_c_idx
	on rhnAuditTrail(id, org_id, user_id, created)
	tablespace [[4m_tbs]
	storage ( freelists 16 )
	initrans 32;
alter table rhnAuditTrail add constraint rhn_audittrail_id_pk primary key (id);

create index rhn_atrail_oid_id_uid_c_idx
	on rhnAuditTrail(org_id, id, user_id, created)
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create index rhn_atrail_uid_id_oid_c_idx
	on rhnAuditTrail(user_id, id, org_id, created)
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create or replace trigger
rhn_audittrail_mod_trig
before insert or update on rhnAuditTrail
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/12/02 15:19:26  pjones
-- audit trail schema
--
