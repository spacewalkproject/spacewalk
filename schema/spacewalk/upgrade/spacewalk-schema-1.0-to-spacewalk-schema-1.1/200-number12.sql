
alter table rhn_command modify ( recid number );
alter table rhn_command_parameter modify ( command_id number );
alter table rhn_command_target modify ( recid number );
alter table rhn_contact_groups modify ( recid number );
alter table rhn_contact_methods modify ( recid number );
alter table rhn_probe modify ( recid number );
alter table rhn_sat_cluster modify ( recid number );

