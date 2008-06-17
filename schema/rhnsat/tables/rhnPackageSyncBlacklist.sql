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

create table
rhnPackageSyncBlacklist
(
	package_name_id		number
				constraint rhn_packagesyncbl_pnid_nn not null
				constraint rhn_packagesyncbl_pnid_fk
					references rhnPackageName(id),
	org_id			number
				constraint rhn_packagesyncbl_oid_fk
					references web_customer(id)
					on delete cascade,
	created			date default(sysdate)
				constraint rhn_packagesyncbl_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_packagesyncbl_mod_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_packagesyncbl_pnid_oid_uq on
	rhnPackageSyncBlacklist( package_name_id, org_id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- for the delete cascade
create index rhn_packagesyncbl_oid_idx on
	rhnPackageSyncBlacklist( org_id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create or replace trigger
rhn_packagesyncbl_mod_trig
before insert or update on rhnPackageSyncBlacklist
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.1  2004/01/28 20:17:54  pjones
-- bugzilla: 113511 -- tables for blacklisting packages from sync
--
