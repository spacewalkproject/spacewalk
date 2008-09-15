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
-- $Id$
--
-- This maintains information about the current schema version,
-- and maximum and minimum server and website versions
--

create table
rhnVersionInfo
(
	label		varchar2(64)
			constraint rhn_versioninfo_label_nn not null,
	name_id		number
			constraint rhn_versioninfo_nid_nn not null
			constraint rhn_versioninfo_nid_fk
				references rhnPackageName(id),
	evr_id		number
			constraint rhn_versioninfo_eid_nn not null
			constraint rhn_versioninfo_eid_fk
				references rhnPackageEVR(id),
	created		date default(sysdate)
			constraint rhn_versioninfo_created_nn not null,
	modified		date default(sysdate)
			constraint rhn_versioninfo_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_versioninfo_label_uq
	on rhnVersionInfo(label)
	tablespace [[64k_tbs]]
	storage ( pctincrease 1 freelists 16 )
	initrans 32;

create index rhn_vinfo_label_eid_nid_idx
	on rhnVersionInfo(label, name_id, evr_id)
	tablespace [[64k_tbs]]
	storage ( pctincrease 1 freelists 16 )
	initrans 32;

create unique index rhn_versioninfo_nid_eid_uq
	on rhnVersionInfo(name_id,evr_id)
	tablespace [[64k_tbs]]
	storage ( pctincrease 1 freelists 16 )
	initrans 32;

create or replace trigger
rhn_versioninfo_mod_trig
before insert or update on rhnVersionInfo
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.7  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.6  2002/05/10 22:00:49  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
