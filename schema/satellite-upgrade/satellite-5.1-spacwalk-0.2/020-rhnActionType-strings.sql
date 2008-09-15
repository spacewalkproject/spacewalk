
update rhnActionType
set name = 'Spacewalk Daemon Configuration'
where label = 'rhnsd.configure';

update rhnActionType
set name = 'Allows for rhn-applet use with an Spacewalk'
where label = 'rhn_applet.use_satellite';

update rhnActionType
set name = 'Subscribes a server to the Spacewalk Tools channel associated with its base channel.'
where label = 'kickstart_host.add_tools_channel';

update rhnActionType
set name = 'Subscribes a virtualization guest to the Spacewalk Tools channel associated with its base channel.'
where label = 'kickstart_guest.add_tools_channel';

