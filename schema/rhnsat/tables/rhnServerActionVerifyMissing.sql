--
-- $Id$
--

create table
rhnServerActionVerifyMissing
(
	server_id		number
				constraint rhn_sactionvm_sid_nn not null
				constraint rhn_sactionvm_sid_fk
					references rhnServer(id),
	action_id		number
				constraint rhn_sactionvm_aid_nn not null
				constraint rhn_sactionvm_aid_fk
					references rhnAction(id)
					on delete cascade,
	package_name_id		number
				constraint rhn_sactionvm_pnid_nn not null
				constraint rhn_sactionvm_pnid_fk
					references rhnPackageName(id),
	package_evr_id		number
				constraint rhn_sactionvm_peid_nn not null
				constraint rhn_sactionvm_peid_fk
					references rhnPackageevr(id),
	package_arch_id		number
				constraint rhn_sactionvm_paid_nn not null
				constraint rhn_sactionvm_paid_fk
					references rhnPackageArch(id),
	package_capability_id	number
				constraint rhn_sactionvm_pcid_nn not null
				constraint rhn_sactionvm_pcid_fk
					references rhnPackageCapability(id),
	created			date default(sysdate)
				constraint rhn_sactionvm_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_sactionvm_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_sactionvm_sanec_uq
	on rhnServerActionVerifyMissing(
		server_id, action_id,
		package_name_id, package_evr_id, package_capability_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_sactionvm_mod_trig
before insert or update on rhnServerActionVerifyMissing
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.1  2004/07/13 19:52:05  pjones
-- bugzilla: 127558 -- table to store missing files during verify
--
