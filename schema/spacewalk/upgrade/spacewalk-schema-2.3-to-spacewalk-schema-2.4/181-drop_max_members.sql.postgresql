-- oracle equivalent source sha1 25e005f8a44df66109e92e51797d385c6b62129a

DROP VIEW rhnVisServerGroupMembership;
DROP VIEW rhnUsersInOrgOverview;
DROP VIEW rhnVisibleServerGroup;

ALTER TABLE rhnServerGroup DROP COLUMN max_members;
SELECT logging.recreate_trigger('rhnservergroup');

CREATE OR REPLACE VIEW
rhnVisibleServerGroup
AS
  SELECT *
    FROM rhnServerGroup SG
   WHERE SG.group_type IS NULL;

create or replace view rhnUsersInOrgOverview as
select    
  u.org_id          as org_id,
  u.id            as user_id,
  u.login           as user_login,
  pi.first_names          as user_first_name,
  pi.last_name          as user_last_name,
  u.modified          as user_modified,
      ( select  count(server_id)
    from  rhnUserServerPerms sp
    where sp.user_id = u.id)
              as server_count,
  ( select  count(server_group_id)
    from  rhnUserManagedServerGroups umsg
    where umsg.user_id = u.id and exists (
      select  1
      from  rhnVisibleServerGroup sg
      where sg.id = umsg.server_group_id))
              as server_group_count,
  coalesce(rhn_user.role_names(u.id), '(normal user)') as role_names
from  web_user_personal_info pi, 
  web_contact u 
where
  u.id = pi.web_user_id;

CREATE OR REPLACE VIEW rhnVisServerGroupMembership (
         ORG_ID, SERVER_ID, GROUP_ID, GROUP_NAME, GROUP_TYPE, CURRENT_MEMBERS
)
AS
SELECT   SG.org_id, SGM.server_id, SG.id, SG.name, SGT.label, SG.current_members
  FROM
   rhnServerGroupMembers SGM
            right outer join
       rhnVisibleServerGroup SG on (SG.id = SGM.server_group_id)
            left outer join
         rhnServerGroupType SGT on (SG.group_type = SGT.id)
;