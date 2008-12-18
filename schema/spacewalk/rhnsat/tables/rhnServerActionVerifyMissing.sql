--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
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
	enable row movement
  ;

create unique index rhn_sactionvm_sanec_uq
	on rhnServerActionVerifyMissing(
		server_id, action_id,
		package_name_id, package_evr_id, package_arch_id,
		package_capability_id )
	tablespace [[4m_tbs]]
  ;

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
-- Revision 1.2  2008/11/04 bbuckingham
-- bugzilla: 456539 - adding package_arch_id to index
--
-- Revision 1.1  2004/07/13 19:52:05  pjones
-- bugzilla: 127558 -- table to store missing files during verify
--
