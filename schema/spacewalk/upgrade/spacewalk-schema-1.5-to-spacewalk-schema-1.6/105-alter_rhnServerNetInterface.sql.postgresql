-- oracle equivalent source sha1 2af124a22b0ff1cfd11f4b92660ed689957c9255

alter table rhnServerNetInterface add id numeric;

create sequence rhn_srv_net_iface_id_seq;

alter table rhnServerNetInterface disable trigger rhn_srv_net_iface_mod_trig;
update rhnServerNetInterface set id = nextval('rhn_srv_net_iface_id_seq');
alter table rhnServerNetInterface enable trigger rhn_srv_net_iface_mod_trig;

alter table rhnServerNetInterface alter column id set not null;

alter table rhnServerNetInterface add constraint rhn_srv_net_iface_id_pk primary key ( id );
