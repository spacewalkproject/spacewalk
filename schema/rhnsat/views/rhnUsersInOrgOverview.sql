-- $Id$
--
create or replace view rhnUsersInOrgOverview as
select    
	u.org_id					org_id,
	u.id						user_id,
	u.login						user_login,
	pi.first_names					user_first_name,
	pi.last_name					user_last_name,
	u.modified					user_modified, 
    	(	select	count(server_id)
		from	rhnUserServerPerms sp
		where	sp.user_id = u.id)
							server_count, 
	(	select	count(server_group_id)
		from	rhnUserManagedServerGroups umsg
		where	umsg.user_id = u.id and exists (
			select	1
			from	rhnVisibleServerGroup sg
			where	sg.id = umsg.server_group_id))
							server_group_count,
	(	select	nvl(utcv.names, '(normal user)')
		from	rhnUserTypeCommaView utcv
		where	utcv.user_id = u.id)
							role_names
from	web_user_personal_info pi, 
	web_contact u 
where
	u.id = pi.web_user_id;

-- $Log$
-- Revision 1.10  2002/06/04 15:15:11  pjones
-- change messaging
--
-- Revision 1.9  2002/05/07 15:20:20  pjones
-- misnamed column?  how the heck did that happen?
--
-- Revision 1.8  2001/12/28 18:04:22  pjones
-- chip has no style.
--
-- Revision 1.7  2001/11/06 23:08:48  cturner
-- sql updtes
--
-- Revision 1.6  2001/10/27 05:21:54  cturner
-- sql changes to move away from permissions being based on usergroups and instead directly on users
--
-- Revision 1.5  2001/07/01 22:43:53  cturner
-- fixing view typo, then will rename in cvsroot.  also changing from rhnOrg to web_customer
--
-- Revision 1.4  2001/06/29 08:30:53  cturner
-- more underscore changes, plus switching from rhnUser to web_contact.  may switch back later, but avoiding synonyms and such seems to make things cleaner
--
-- Revision 1.3  2001/06/27 02:05:25  gafton
-- add Log too
--
