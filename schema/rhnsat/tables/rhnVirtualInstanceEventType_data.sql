-- data for rhnVirtualInstanceEventType

insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Create', 'create');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Destroy', 'destroy');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Shutdown', 'shutdown');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Pause', 'pause');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Unpause', 'unpause');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Migrate', 'migrate');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Vcpu-Set', 'vcpu-set');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Mem-Set', 'mem-set');
