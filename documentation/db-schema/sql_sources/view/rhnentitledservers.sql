-- created by Oraschemadoc Fri Jan 22 13:40:42 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM_H1"."RHNENTITLEDSERVERS" ("ID", "ORG_ID", "DIGITAL_SERVER_ID", "SERVER_ARCH_ID", "OS", "RELEASE", "NAME", "DESCRIPTION", "INFO", "SECRET") AS 
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
