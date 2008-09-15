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

-- $Id$
create table rhnSolarisPatchSetMembers (
   patch_id          number
                     constraint rhn_solaris_psm_pid_nn not null
                     constraint rhn_solaris_psm_pid_fk references rhnPackage(id)
                     on delete cascade,
   patch_set_id      number
                     constraint rhn_solaris_psm_psid_nn not null
                     constraint rhn_solaris_psm_psid_fk references rhnPackage(id)
                     on delete cascade,
   patch_order       number,
   created           date default(sysdate)
                     constraint rhn_solaris_psm_created_nn not null,
   modified          date default(sysdate)
                     constraint rhn_solaris_psm_modified_nn not null
)
tablespace [[8m_data_tbs]]
storage( pctincrease 1 freelists 16 )
enable row movement
initrans 32;

create index rhn_solaris_psm_pid_psid_idx
on rhnSolarisPatchSetMembers (patch_id, patch_set_id)
tablespace [[4m_tbs]]
storage ( freelists 16 )
initrans 32;

create index rhn_solaris_psm_psid_pid_idx
on rhnSolarisPatchSetMembers (patch_set_id, patch_id)
tablespace [[4m_tbs]]
storage ( freelists 16 )
initrans 32;

create trigger
rhn_solaris_psm_mod_trig
before update on rhnSolarisPatchSetMembers
for each row
begin
   :new.modified := sysdate;
end;
/
show errors;

-- $Log$
