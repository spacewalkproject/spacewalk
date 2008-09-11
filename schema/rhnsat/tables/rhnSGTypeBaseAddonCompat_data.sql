
--
-- $Id$
--

insert into rhnSGTypeBaseAddonCompat (base_id, addon_id)
values (lookup_sg_type('enterprise_entitled'), 
        lookup_sg_type('monitoring_entitled'));

insert into rhnSGTypeBaseAddonCompat (base_id, addon_id)
values (lookup_sg_type('enterprise_entitled'), 
        lookup_sg_type('provisioning_entitled'));

insert into rhnSGTypeBaseAddonCompat (base_id, addon_id)
values (lookup_sg_type('enterprise_entitled'), 
        lookup_sg_type('virtualization_host'));

insert into rhnSGTypeBaseAddonCompat (base_id, addon_id)
values (lookup_sg_type('enterprise_entitled'), 
        lookup_sg_type('virtualization_host_platform'));

insert into rhnSGTypeBaseAddonCompat (base_id, addon_id)
values (lookup_sg_type('sw_mgr_entitled'), 
        lookup_sg_type('virtualization_host'));

insert into rhnSGTypeBaseAddonCompat (base_id, addon_id)
values (lookup_sg_type('sw_mgr_entitled'), 
        lookup_sg_type('virtualization_host_platform'));

commit;

--
-- $Log: $
--


