-- data for rhnVirtualInstanceState

insert into rhnVirtualInstanceState (id, name, label) values (rhn_vis_id_seq.nextval, 'Unknown', 'unknown');
insert into rhnVirtualInstanceState (id, name, label) values (rhn_vis_id_seq.nextval, 'Running', 'running');
insert into rhnVirtualInstanceState (id, name, label) values (rhn_vis_id_seq.nextval, 'Stopped', 'stopped');
insert into rhnVirtualInstanceState (id, name, label) values (rhn_vis_id_seq.nextval, 'Crashed', 'crashed');
insert into rhnVirtualInstanceState (id, name, label) values (rhn_vis_id_seq.nextval, 'Paused', 'paused');

