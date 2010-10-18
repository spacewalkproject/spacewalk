alter table rhnChannelNewestPackage disable constraint rhn_cnp_cid_nid_uq;
drop index rhn_cnp_cnep_idx;
alter table rhnChannelNewestPackage enable constraint rhn_cnp_cid_nid_uq;

drop index rhn_cnp_necp_idx;
drop index rhn_cnp_pid_idx;

