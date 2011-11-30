alter table rhnServerNetInterface add id number;

create sequence rhn_srv_net_iface_id_seq;

update rhnServerNetInterface set id = rhn_srv_net_iface_id_seq.nextval;

alter table rhnServerNetInterface modify id number not null;

alter table rhnServerNetInterface add constraint rhn_srv_net_iface_id_pk primary key ( id );
