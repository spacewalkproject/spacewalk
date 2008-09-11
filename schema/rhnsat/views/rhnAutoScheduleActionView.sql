-- This view is used for extracting data needed by the mail_errata script
--
-- $Id$
--
-- EXCLUDE: all

-- work in progress
create or replace view
rhnAutoScheduleErrataView
as
select
	w.login, 
	w.login_uc,
	wpi.email,  
	w.id user_id,
	s.id server_id,  
	s.org_id org_id, 
	s.digital_server_id,  
	s.name server_name,  
	sa.name server_arch,  
	s.release server_release,  
	e.id errata_id,
	e.advisory_type type, 
	e.advisory, 
	e.synopsis, 
	e.description, 
	e.notes
from
	web_contact w, 
	web_user_personal_info wpi,
	rhnUserPrefs upref,
	rhnServer s,
	rhnServerArch sa,
	rhnErrata e
where
        s.server_arch_id = sa.id
    and w.id = wpi.web_user_id
    and exists (
        select 1
	from
	    rhnServerGroupMembers sgm,
	    rhnServerGroup sg,
	    rhnServerGroupType sgt
	where
	    s.id = sgm.server_id
	and sgm.server_group_id = sg.id
	and sg.org_id = w.org_id
	and sg.group_type = sgt.id
	and sgt.label = 'sw_mgr_entitled'
	)
    and w.org_id = s.org_id
    and exists (
        select 1
	from
	    rhnPackageEVR p_evr,
	    rhnPackageEVR sp_evr,
	    rhnServerPackage sp,
	    rhnServerPackageArchCompat spac,
	    rhnServerChannel sc,
	    rhnChannelPackage cp,
	    rhnPackage p,
	    rhnErrataPackage ep
	where
	    sc.server_id = s.id
	and sc.channel_id = cp.channel_id
	and cp.package_id = p.id
	and p.package_arch_id = spac.package_arch_id
	and spac.server_arch_id = s.server_arch_id
	and sp_evr.id = sp.evr_id
	and p_evr.id = p.evr_id
	and p.id = ep.package_id
	and ep.errata_id = e.id
	and sp.server_id = s.id
	and sp.name_id = p.name_id
	and sp.evr_id != p.evr_id
	and sp_evr.evr < p_evr.evr )
--  and sp_evr.evr = (select max(pe.evr) 
--		      from rhnServerPackage sp2, rhnPackageEvr pe 
--		      where pe.id = sp2.evr_id 
--		        and sp2.server_id = sp.server_id 
--			and sp2.name_id = sp.name_id)
    and exists (
        select 1
	from
	    rhnUserGroupMembers ugm, 
	    rhnServerGroupMembers sgm,
	    rhnUserGroupServerGroupPerms ugsg
	where
	    ugm.user_group_id = ugsg.user_group_id 
	and ugsg.server_group_id = sgm.server_group_id
	and w.id = ugm.user_id
	and s.id = sgm.server_id 
	UNION ALL
	select 1
	from  
	    rhnUserGroup ug,
	    rhnUserGroupType ugt,
	    rhnUserGroupMembers ugm 
	where 
	    w.id = ugm.user_id
	and ugm.user_group_id = ug.id 
	and s.org_id = ug.org_id 
	and ug.group_type = ugt.id
	and ugt.label = 'org_admin'
	)
    and w.id = upref.user_id
    and upref.name = 'user_email_notify'
    and upref.value = '1'
    and 0 = ( select count(server_id) 
              from rhnUserServerPrefs usprefs
	      where
	          w.id = usprefs.user_id 
	      and s.id = usprefs.server_id 
	      and usprefs.name = 'receive_notifications' )
/

-- $Log$
-- Revision 1.3  2002/11/14 17:20:34  pjones
-- arch -> *_arch_id and archCompat changes
--
-- Revision 1.2  2002/05/08 23:10:12  gafton
-- Make file exclusion work correctly
--
-- Revision 1.1  2001/09/13 19:12:29  gafton
-- updated
--
-- Revision 1.2  2001/09/07 10:21:08  gafton
-- a tiny bit of optimization
--
-- Revision 1.1  2001/09/07 07:37:47  gafton
-- helper view for mailing errata out
--
