
alter table rhn_sat_node_probe disable constraint rhn_sndpb_probe_id_pk;
drop index rhn_sndpb_pid_ptype_idx;
alter table rhn_sat_node_probe enable constraint rhn_sndpb_probe_id_pk;

