alter table rhnKSTreeFile disable constraint rhn_kstreefile_kid_fk;
alter table rhnKickstartDefaults disable constraint rhn_ksd_kstid_fk;
alter table rhnKickstartSession disable constraint rhn_ks_session_kstid_fk;
alter table rhnKickstartableTree disable constraint rhn_kstree_id_pk;
drop index rhn_kstree_id_pk;
alter table rhnKickstartableTree enable constraint rhn_kstree_id_pk;
alter table rhnKSTreeFile enable constraint rhn_kstreefile_kid_fk;
alter table rhnKickstartDefaults enable constraint rhn_ksd_kstid_fk;
alter table rhnKickstartSession enable constraint rhn_ks_session_kstid_fk;
