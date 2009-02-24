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
--

create table rhnSolarisPatch (
   package_id        numeric
                     constraint rhn_solaris_p_pk primary key
                     constraint rhn_solaris_p_fk references rhnPackage(id)
                     on delete cascade,
   solaris_release   varchar(64),
   sunos_release     varchar(64),
   patch_type        numeric
                     not null
                     constraint rhn_solaris_p_pt_fk references rhnSolarisPatchType (id)
                     on delete set null,
   created           date default(current_date)
                     not null,
   modified          date default(current_date)
                     not null,
   readme            bytea
                     not null,
   patchinfo         varchar(4000)
)
--	tablespace [[8m_data_tbs]]
  ;

/*create trigger
rhn_solaris_p_mod_trig
before update on rhnSolarisPatch
for each row
begin
   :new.modified := sysdate;
end;
/
show errors;
*/

--
--
-- Revision 1.1  2003/09/11 20:55:42  pjones
-- bugzilla: 104231
--
-- tables to handle kickstart data
--

