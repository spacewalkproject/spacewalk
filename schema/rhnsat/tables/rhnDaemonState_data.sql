--
-- $Id$
--
-- data for the entitlement poll
--

-- we don't have a great way to exclude 'entitlement_run_me' on satellite.
-- no big deal though, it just won't get used.
insert into rhnDaemonState values ('entitlement_run_me',sysdate-1000);
insert into rhnDaemonState values ('email_engine',sysdate-1000);
insert into rhnDaemonState values ('payloader_engine',sysdate-1000);
insert into rhnDaemonState values ('pushed_users',sysdate-1000);
commit;

-- $Log$
-- Revision 1.2  2003/01/24 16:18:50  pjones
-- fix initial inserts here too
--
-- Revision 1.1  2003/01/13 22:59:03  pjones
-- rhnDaemonState population and grants/synonyms
--
