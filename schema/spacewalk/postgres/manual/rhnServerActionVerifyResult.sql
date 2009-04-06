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
rhnServerActionVerifyResult
(
	server_id		numeric
				not null
				constraint rhn_sactionvr_sid_fk
				references rhnServer(id),
	action_id		numeric
				not null
				constraint rhn_sactionvr_aid_fk
				references rhnAction(id)
				on delete cascade,
	package_name_id		numeric
				not null
				constraint rhn_sactionvr_pnid_fk
				references rhnPackageName(id),
	package_evr_id		numeric
				not null
				constraint rhn_sactionvr_peid_fk
				references rhnPackageEVR(id),
	package_arch_id		numeric
				not null
				constraint rhn_sactionvr_paid_fk
				references rhnPackageArch(id),
	package_capability_id	numeric
				not null
				constraint rhn_sactionvr_pcid_fk
				references rhnPackageCapability(id),
	attribute		char(1)
				constraint rhn_sactionvr_attr_ck
					check (attribute in ('c','d','g','l','r')),
	size_differs		char(1)
				not null
				constraint rhn_sactionvr_size_ck
					check (size_differs in ('Y','N','?')),
	mode_differs		char(1)
				not null
				constraint rhn_sactionvr_mode_ck
					check (mode_differs in ('Y','N','?')),
	md5_differs		char(1)
				not null
				constraint rhn_sactionvr_md5_ck
					check (md5_differs in ('Y','N','?')),
	devnum_differs		char(1)
				not null
				constraint rhn_sactionvr_devnum_ck
					check (devnum_differs in ('Y','N','?')),
	readlink_differs	char(1)
				not null
				constraint rhn_sactionvr_readlink_ck
					check (readlink_differs in ('Y','N','?')),
	uid_differs		char(1)
				not null
				constraint rhn_sactionvr_uid_ck
					check (uid_differs in ('Y','N','?')),
	gid_differs		char(1)
				not null
				constraint rhn_sactionvr_gid_ck
					check (gid_differs in ('Y','N','?')),
	mtime_differs		char(1)
				not null
				constraint rhn_sactionvr_mtime_ck
					check (mtime_differs in ('Y','N','?')),
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null,
                                constraint rhn_sactionvr_sanec_uq
                                unique(server_id, action_id,package_name_id, package_evr_id,
                                       package_arch_id,package_capability_id )
--                              using index tablespace [[4m_tbs]]
)

  ;

/*
create or replace trigger
rhn_sactionvr_mod_trig
before insert or update on rhnServerActionVerifyResult
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.9  2008/11/04 bbuckingham
-- bugzilla: 456539 - adding package_arch_id to index
--
-- Revision 1.8  2004/04/14 22:22:40  pjones
-- bugzilla: none -- we're doing evr and arch every time now, let's make them
-- not null to start with.
--
-- Revision 1.7  2004/04/14 01:23:28  pjones
-- bugzilla: none -- er, not on attr, just on *_differs
--
-- Revision 1.6  2004/04/14 01:12:22  pjones
-- bugzilla: 101315 -- allow '?' for all of the _differs columns
--
-- Revision 1.5  2004/04/08 20:26:29  pjones
-- bugzilla: none -- capability id should be part of the uniqueness
--
-- Revision 1.4  2004/04/08 20:01:09  pjones
-- bugzilla: 101315 -- verify results must be associated with servers
--
-- Revision 1.3  2004/04/08 19:30:12  pjones
-- bugzilla: none -- reformat
--
-- Revision 1.2  2004/03/15 16:41:57  pjones
-- bugzilla: 118245 -- on delete cascades for deleting actions
--
-- Revision 1.1  2003/12/09 20:05:47  pjones
-- bugzilla: 101315 -- schema for verify action results
--
