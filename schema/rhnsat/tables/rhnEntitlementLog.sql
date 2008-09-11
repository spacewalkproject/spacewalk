--
-- $Id$
--
-- log of when entitlement_run_me is run, and with what dates it runs
-- poll_entitlements

create table
rhnEntitlementLog
(
	run_time	date default(sysdate)
			constraint rhn_entitlement_log_rt_nn not null,
	bdate		date
			constraint rhn_entitlement_log_bdate_nn not null,
	edate		date
			constraint rhn_entitlement_log_edate_nn not null
)
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/10/04 19:23:13  pjones
-- I hate having to do this.
--
