drop index rhn_ug_org_id_name_idx;

ALTER TABLE rhnUserGroup
 disable CONSTRAINT rhn_ug_oid_gt_uq;
drop index rhn_ug_org_id_gtype_idx;
ALTER TABLE rhnUserGroup
 enable CONSTRAINT rhn_ug_oid_gt_uq
 USING INDEX TABLESPACE [[8m_tbs]];
