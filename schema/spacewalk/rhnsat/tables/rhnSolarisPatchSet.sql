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

create table rhnSolarisPatchSet (
   package_id        number
                     constraint rhn_solaris_ps_pid_pk primary key
                     constraint rhn_solaris_ps_pid_fk references rhnPackage(id)
                     on delete cascade,
   readme            blob,
   set_date          date default(sysdate)
                     constraint rhn_solaris_ps_sd_nn not null,
   created           date default(sysdate)
                     constraint rhn_solaris_ps_created_nn not null,
   modified          date default(sysdate)
                     constraint rhn_solaris_ps_modified_nn not null
)
tablespace [[8m_data_tbs]]
storage( pctincrease 1 freelists 16 )
enable row movement
initrans 32;

create sequence rhn_solaris_ps_seq;

create or replace trigger
rhn_solaris_ps_mod_trig
before insert or update on rhnSolarisPatchSet
for each row
begin
   :new.modified := sysdate;
end;
/
show errors;

--
