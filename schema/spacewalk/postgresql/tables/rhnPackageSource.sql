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
rhnPackageSource
(
        id              numeric
                        constraint rhn_pkgsrc_id_pk primary key
--			using index tablespace [[64k_tbs]]
			,
        org_id          numeric
                        constraint rhn_pkgsrc_oid_fk
			references web_customer(id)
			on delete cascade,
	source_rpm_id	numeric
			not null
			constraint rhn_pkgsrc_srid_fk
			references rhnSourceRPM(id),
        package_group   numeric
			not null
                        constraint rhn_pkgsrc_group_fk
			references rhnPackageGroup(id),
        rpm_version     varchar(16)
			not null,
        payload_size    numeric
			not null,
        build_host      varchar(256)
			not null,
        build_time      date
			not null,
        -- In case they resigned the source package
        sigmd5          varchar(64)
			not null,
        vendor          varchar(64)
			not null,
	cookie		varchar(128)
			not null,
        path            varchar(1000),
        md5sum          varchar(64)
	                not null,
        package_size    numeric
	                not null,
	last_modified	date default (current_date)
			not null,
        created         date default (current_date)
			not null,
        modified        date default (current_date)
			not null,
                        constraint rhn_pkgsrc_srid_oid_uq
                        unique(source_rpm_id, org_id)
--                      using index tablespace [[64k_tbs]]
)
  ;

create sequence rhn_package_source_id_seq;

/*
create or replace trigger
rhn_pkgsrc_mod_trig
before insert or update on rhnPackageSource
for each row
begin
        :new.modified := sysdate;
	:new.last_modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.19  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.18  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.17  2003/01/24 16:42:23  pjones
-- last_modified on rhnPackage and rhnPackageSource
--
-- Revision 1.16  2002/05/28 20:56:40  misa
-- Updated the source packages schema
--
-- Revision 1.15  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
