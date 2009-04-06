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
--/

-- this is how requires works... poorly.
-- you can do:
--
-- select
--      cap1.id
-- from
--      rhnCapability cap1,
--      rhnCapability cap2,
--      rhnPackageRequires req
-- where 
--      cap2.id = req.capabilityId
--      and cap1.name = cap2.name
--      and cap1.arch = cap2.arch
--      and cap1.id > cap2.id
create table
rhnPackageRequires
(
        package_id      numeric
                        not null
                        constraint rhn_pkg_requires_package_fk
                        references rhnPackage(id)
                        on delete cascade,
        capability_id   numeric
                        not null
                        constraint rhn_pkg_requires_capability_fk
                        references rhnPackageCapability(id),
        sense           numeric default(0) -- comes from RPMSENSE_*
                        not null,
        created         date default (current_date)
                        not null,
        modified        date default (current_date)
                        not null,
                        constraint rhn_pkg_req_pid_cid_s_uq
                        unique(package_id, capability_id, sense)
--                      using index tablespace [[4m_tbs]]
)
  ;

create index rhn_pkg_requires_cid_idx
	on rhnPackageRequires(capability_id)
--      tablespace [[4m_tbs]]
        ;

/*
create or replace trigger
rhn_pkg_requires_mod_trig
before insert or update on rhnPackageRequires
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.12  2004/12/07 20:18:56  cturner
-- bugzilla: 142156, simplify the triggers
--
-- Revision 1.11  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.10  2003/01/24 16:42:23  pjones
-- last_modified on rhnPackage and rhnPackageSource
--
-- Revision 1.9  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
