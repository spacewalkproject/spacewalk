update rhn_config_parameter
	set value = '%{NPVAR}/execute_commands.log'
	where group_name = 'CommandQueue' and name = 'exelog';
