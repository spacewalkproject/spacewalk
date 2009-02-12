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
--/

create table
rhnOrgEntitlements
(
        org_id          numeric
                        not null
                        constraint rhn_org_ent_fk
                        references web_customer(id)
			on delete cascade,
        entitlement_id  numeric
                        not null
                        constraint rhn_org_ent_eid_fk
                        references rhnOrgEntitlementType(id),
        created         date default(current_date)
                        not null,
        modified        date default(current_date)
                        not null,
                        constraint rhn_org_ent_org_eid_uq
                        unique(org_id, entitlement_id)
--                      using index tablespace [[2m_tbs]]
)
  ;

/*
create or replace trigger
rhn_org_ent_mod_trig
before insert or update on rhnOrgEntitlements
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.6  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.5  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.4  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.3  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[2m_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.2  2001/12/27 18:22:01  pjones
-- policy change: foreign keys to other users' tables now _always_ go to
-- a synonym.  This makes satellite schema (where web_contact is in the same
-- namespace as rhn*) easier.
--
-- Revision 1.1  2001/07/25 14:40:50  cturner
-- initial shot at tracking org level entitlements, plus making the rhn:require tag work now
--
--/

