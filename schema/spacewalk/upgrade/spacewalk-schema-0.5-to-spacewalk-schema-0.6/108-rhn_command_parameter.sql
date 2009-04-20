-- In Satellite 5.1.0 (svn rev. 136500, bug #429529) input field for
-- "SNMP Community String" was mistakenly changed from 'text' to
-- 'password'. This caused web forms for creating "General: SNMP Check"
-- and "General: Uptime (SNMP)" to be rendered incorrectly.

update rhn_command_parameter
	set field_widget_name = 'text' where
	command_id in (16, 113) and param_name = 'community';

commit;
