--
-- $Id$
--
create table
rhnActionErrataUpdate
(
	action_id       number
			constraint rhn_act_eu_act_nn not null
			constraint rhn_act_eu_act_fk 
				references rhnAction(id)
				on delete cascade,
	errata_id       number
			constraint rhn_act_eu_err_nn not null
			constraint rhn_act_eu_err_fk 
				references rhnErrata(id)
				on delete cascade
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_act_eu_aid_eid_idx
	on rhnActionErrataUpdate(action_id, errata_id)
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_act_eu_eid_aid_idx
	on rhnActionErrataUpdate(errata_id, action_id)
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.14  2003/08/21 21:29:29  pjones
-- bugzilla: 102263
--
-- index (errata_id,action_id) instead of just errata_id
--
-- Revision 1.13  2003/08/19 14:51:51  uid2174
-- bugzilla: 102263
--
-- indices
--
-- Revision 1.12  2003/08/14 19:59:07  pjones
-- bugzilla: none
--
-- reformat "on delete cascade" on things that reference rhnErrata*
--
-- Revision 1.11  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.10  2002/10/25 15:52:02  misa
-- Better explain plans
--
-- Revision 1.9  2002/04/26 23:34:35  gafton
-- Add the required "on delete cascade" constraints to make these tables work
-- with the serverless actions cleanup scripts.
--
-- Chip, Peter, please make sure to integrate these changes into our devel,
-- QA and live anvrionments.
--
-- Revision 1.8  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
