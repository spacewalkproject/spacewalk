insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'tasks',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'critical-systems',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'critical-probes','show_monitoring();');
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'warning-probes','show_monitoring();');
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'system-groups-widget','org_entitlement(sw_mgr_enterprise);');
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'latest-errata',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'inactive-systems',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'pending-actions',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval, 'recently-registered-systems', null);
