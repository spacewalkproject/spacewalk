--
-- $Id$
--

create or replace view
rhnEntitledServers
as
select distinct
    S.id,
    S.org_id,
    S.digital_server_id,
    S.server_arch_id,
    S.os,
    S.release,
    S.name,
    S.description,
    S.info,
    S.secret
from
    rhnServerGroup SG,
    rhnServerGroupType SGT,
    rhnServerGroupMembers SGM,
    rhnServer S
where
    S.id = SGM.server_id
and SG.id = SGM.server_group_id
and SGT.label IN ('sw_mgr_entitled', 'enterprise_entitled', 'provisioning_entitled')
and SG.group_type = SGT.id
and SG.org_id = S.org_id
/

-- $Log$
-- Revision 1.9  2004/02/26 20:02:31  cturner
-- fix rhnEntitledservers view for nonlinux entitlement
--
-- Revision 1.8  2003/09/23 15:58:14  cturner
-- bugzilla: 104916ah hah, provisioning counts as an entitled server
--
-- Revision 1.7  2002/11/14 17:20:34  pjones
-- arch -> *_arch_id and archCompat changes
--
-- Revision 1.6  2002/05/15 21:30:09  pjones
-- id/log
--
