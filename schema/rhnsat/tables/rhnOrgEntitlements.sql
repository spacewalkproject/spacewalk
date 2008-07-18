--
-- $Id$
--/

create table
rhnOrgEntitlements
(
        org_id          number
                        constraint rhn_org_ent_nn not null
                        constraint rhn_org_ent_fk
                                references web_customer(id)
				on delete cascade,
        entitlement_id  number
                        constraint rhn_org_ent_eid_nn not null
                        constraint rhn_org_ent_eid_fk
                                references rhnOrgEntitlementType(id),
        created         date default(sysdate)
                        constraint rhn_org_ent_cre_nn not null,
        modified        date default(sysdate)
                        constraint rhn_org_ent_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_org_ent_org_eid_uq
	on rhnOrgEntitlements(org_id, entitlement_id)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_org_ent_mod_trig
before insert or update on rhnOrgEntitlements
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

--
-- $Log$
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

