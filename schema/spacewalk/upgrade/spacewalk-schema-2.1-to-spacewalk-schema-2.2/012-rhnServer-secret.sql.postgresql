-- oracle equivalent source sha1 30d6773a245f94375946955d301fadd5888e0a24

drop view rhnentitledservers;

alter table rhnServer alter column secret type varchar(64);

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
;

alter table rhnServer_log alter column secret type varchar(64);

select logging.recreate_trigger('rhnserver');
