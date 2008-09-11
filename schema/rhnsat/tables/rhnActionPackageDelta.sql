--
-- $Id$
--

create table
rhnActionPackageDelta
(
	action_id		number
				constraint rhn_act_pd_aid_nn not null
				constraint rhn_act_pd_aid_fk
					references rhnAction(id)
					on delete cascade,
	package_delta_id	number
				constraint rhn_act_pd_pdid_nn not null
				constraint rhn_act_pd_pdid_fk
					references rhnPackageDelta(id)
					on delete cascade
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_act_pd_aid_pdid_idx
	on rhnActionPackageDelta(action_id, package_delta_id)
	tablespace [[8m_tbs]]
	storage ( pctincrease 1 freelists 16 )
	initrans 32
	nologging;

-- $Log$
-- Revision 1.2  2003/07/01 14:09:11  pjones
-- bugzilla: 90374 -- fix missing constraint
--
-- Revision 1.1  2003/06/10 19:42:25  pjones
-- package delta actions
--
