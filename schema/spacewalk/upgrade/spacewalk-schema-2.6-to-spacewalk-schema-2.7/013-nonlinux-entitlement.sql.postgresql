-- oracle equivalent source sha1 fa1baf4e35534131be7c80f2bec07bfcd751abd3

select logging.clear_log_id();

delete from rhnServerGroupMembers where server_group_id in (select id from rhnServerGroup where name = 'Non-Linux Entitled Servers' and group_type is not null);

delete from rhnServerGroup where name = 'Non-Linux Entitled Servers' and group_type is not null;

delete from rhnServerGroupType where label = 'nonlinux_entitled';
