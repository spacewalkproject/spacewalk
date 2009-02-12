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
rhnPackage
(
        id              numeric not null
                        constraint rhn_package_id_pk primary key
--				using index tablespace [[4m_tbs]]
				,
        org_id          numeric
                        constraint rhn_package_oid_fk
				references web_customer(id)
				on delete cascade,
        name_id         numeric not null
                        constraint rhn_package_nid_fk
				references rhnPackageName(id),
        evr_id          numeric not null
                        constraint rhn_package_eid_fk
				references rhnPackageEvr(id),
	package_arch_id	numeric not null
			constraint rhn_package_paid_fk
				references rhnPackageArch(id),
        package_group   numeric 
                        constraint rhn_package_group_fk
				references rhnPackageGroup(id),
        rpm_version     varchar(16),
        description     varchar(4000),
        summary         varchar(4000),
        package_size    numeric not null,
        payload_size    numeric,
        build_host      varchar(256),
        build_time      date,
	source_rpm_id	numeric
			constraint rhn_package_srcrpmid_fk
				references rhnSourceRPM(id),
        md5sum          varchar(64) not null,
        vendor          varchar(64) not null,
        payload_format  varchar(32),
				-- do we care?
        compat          number(1) default 0
                        constraint rhn_package_compat_check
                                check (compat in (1,0)),
                                -- Y/N .  This makes ``dont use compat if 
                                -- possible'' easier
        path            varchar(1000),
	header_sig	varchar(64),
	copyright	varchar(64),
	cookie		varchar(128),
	last_modified	timestamp default (current_timestamp) not null,
        created         timestamp default (current_timestamp) not null,
        modified        timestamp default (current_timestamp) not null,
        header_start    numeric default -1 not null,
        header_end      numeric default -1 not null,
			constraint rhn_package_md5_oid_uq unique (md5sum, org_id)
--        		using tablespace [[2m_tbs]]
)
  ;

create sequence rhn_package_id_seq;

create index rhn_package_oid_id_idx
	on rhnPackage(org_id, id)
--	tablespace [[64k_tbs]]
	nologging;

create index rhn_package_id_nid_paid_idx
	on rhnPackage(id,name_id, package_arch_id)
--	tablespace [[2m_tbs]]
	nologging;
	
create index rhn_package_nid_id_idx
	on rhnPackage(name_id,id)
--	tablespace [[2m_tbs]]
	nologging;

/*create or replace trigger
rhn_package_mod_trig
before insert or update on rhnPackage
for each row
begin
	-- when we do a sat sync, we use last_modified to keep track
	-- of the upstream modification date.  So if we're setting
	-- it explicitly, don't override with sysdate.  But if we're
	-- not changing it, then this is a genuine update that needs
	-- tracking.
	--
	-- we're not using is_satellite() here instead, because we
	-- might want to use this to keep webdev in sync.
	if :new.last_modified = :old.last_modified then
		:new.last_modified := sysdate;
	end if;       
	:new.modified := sysdate;
end;
/
show errors
*/

--
-- Revision 1.40  2004/02/05 22:49:40  pjones
-- bugzilla: 115011 -- this is at least the first big step towards non-rpm
-- rhnPackage
--
-- Revision 1.39  2003/08/12 20:29:21  pjones
-- bugzilla: none
--
-- typo fix
--
-- Revision 1.38  2003/08/08 18:57:01  pjones
-- bugzilla: 79124
--
-- make last_modified useful for the satellite sync process
--
-- Revision 1.37  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.36  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.35  2003/01/24 16:42:23  pjones
-- last_modified on rhnPackage and rhnPackageSource
--
-- Revision 1.34  2002/12/23 21:39:36  misa
-- arch -> package_arch_id
--
-- Revision 1.33  2002/11/14 18:45:13  misa
-- Changed the index name (too long)
--
-- Revision 1.32  2002/11/14 17:31:37  pjones
-- more arch changes -- remove the old fields
--
-- Revision 1.31  2002/11/13 22:45:20  pjones
-- add appropriate arch fields.
-- haven't deleted the old ones yet though
--
-- Revision 1.30  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
-- Revision 1.29  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
