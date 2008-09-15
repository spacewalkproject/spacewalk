
update rhnServerGroupType
set name = 'Spacewalk Update Entitled Servers'
where label = 'sw_mgr_entitled';

update rhnServerGroupType
set name = 'Spacewalk Management Entitled Servers'
where label = 'enterprise_entitled';

update rhnServerGroupType
set name = 'Spacewalk Provisioning Entitled Servers'
where label = 'provisioning_entitled';

update rhnServerGroupType
set name = 'Spacewalk Monitoring Entitled Servers'
where label = 'monitoring_entitled';

