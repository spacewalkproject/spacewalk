
update rhnKickstartSessionState
set description = 'The system has downloaded the kickstart configuraton file from Spacewalk.'
where label = 'configuration_accessed';

update rhnKickstartSessionState
set description = 'The system has successfully registered with Spacewalk after kickstarting.'
where label = 'registered';

