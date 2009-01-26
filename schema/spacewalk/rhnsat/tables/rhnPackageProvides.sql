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

-- provides is really the same
create table
rhnPackageProvides
(
        package_id      number
                        constraint rhn_pkg_provides_pid_nn not null
                        constraint rhn_pkg_provides_package_fk
                                references rhnPackage(id)
                                on delete cascade,
        capability_id   number
                        constraint rhn_pkg_provides_cid_nn not null
                        constraint rhn_pkg_provides_capability_fk
                                references rhnPackageCapability(id),
        sense           number default(0) -- comes from RPMSENSE_*
                        constraint rhn_pkg_provides_sense_nn not null,
        created         date default (sysdate)
                        constraint rhn_pkg_provides_ctime_nn not null,
        modified        date default (sysdate)
                        constraint rhn_pkg_provides_mtime_nn not null
)
	enable row movement
  ;

create unique index rhn_pkg_prov_cid_pid_s_uq
	on rhnPackageProvides(capability_id, package_id, sense)
	tablespace [[2m_tbs]]
  ;

create index rhn_pkg_provides_pid_idx
	on rhnPackageProvides(package_id)
        nologging tablespace [[2m_tbs]]
  ;

create or replace trigger
rhn_pkg_provides_mod_trig
before insert or update on rhnPackageProvides
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

--
-- Revision 1.10  2004/12/07 20:18:56  cturner
-- bugzilla: 142156, simplify the triggers
--
-- Revision 1.9  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.8  2003/01/24 16:42:23  pjones
-- last_modified on rhnPackage and rhnPackageSource
--
-- Revision 1.7  2002/05/10 21:54:45  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
--
