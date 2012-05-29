alter table rhnServerNetwork modify (ipaddr varchar(16));
alter trigger rhn_servernetwork_mod_trig disable;
update rhnServerNetwork set ipaddr=trim(ipaddr);
alter trigger rhn_servernetwork_mod_trig enable;
