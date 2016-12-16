-- oracle equivalent source sha1 ca7be9ed2a8ef93f8f95adbcf25c38d82f6cc07e

delete from rhnServerGroupMembers where server_group_id in
       (select sg.id
          from rhnServerGroup sg,
               rhnServerGroupType sgt
         where sg.group_type = sgt.id
           and sgt.label = 'monitoring_entitled');
alter table rhnServerGroup disable trigger rhnservergroup_log_trig;
delete from rhnServerGroup where group_type in
       (select id from rhnServerGroupType where label = 'monitoring_entitled');
alter table rhnServerGroup enable trigger rhnservergroup_log_trig;
delete from rhnSgTypeBaseAddOnCompat where addon_id in
       (select id from rhnServerGroupType where label = 'monitoring_entitled');
delete from rhnServerServerGroupArchCompat where server_group_type in
       (select id from rhnServerGroupType where label = 'monitoring_entitled');
delete from rhnServerGroupTypeFeature where server_group_type_id in
       (select id from rhnServerGroupType where label = 'monitoring_entitled');
delete from rhnServerGroupType where label = 'monitoring_entitled';
