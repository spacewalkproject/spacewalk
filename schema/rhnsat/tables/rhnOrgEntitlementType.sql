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
--/

create table
rhnOrgEntitlementType
(
        id              number
			constraint rhn_org_ent_type_id_nn not null
                        constraint rhn_org_ent_type_id_pk primary key
                                using index tablespace [[64k_tbs]],
        label           varchar2(32)
                        constraint rhn_org_ent_type_label_nn not null,
        name            varchar2(64)
                        constraint rhn_org_ent_type_name_nn not null,
        created         date default(sysdate)
                        constraint rhn_org_ent_type_created_nn not null,
        modified        date default(sysdate)
                        constraint rhn_org_ent_type_mod_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_org_entitlement_type_seq;

create unique index rhn_org_entitle_type_label_uq 
	on rhnOrgEntitlementType(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_org_ent_type_mod_trig
before insert or update on rhnOrgEntitlementType
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.5  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.4  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.3  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
-- Revision 1.2  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.1  2001/07/25 14:40:50  cturner
-- initial shot at tracking org level entitlements, plus making the rhn:require tag work now
--
--/

