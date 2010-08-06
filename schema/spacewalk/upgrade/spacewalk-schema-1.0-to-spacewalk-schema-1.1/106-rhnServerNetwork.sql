alter table rhnServerNetwork modify (ipaddr varchar(16));
update rhnServerNetwork set ipaddr=trim(ipaddr);
