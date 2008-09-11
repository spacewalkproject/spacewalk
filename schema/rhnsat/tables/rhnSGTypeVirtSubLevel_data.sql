--
-- $Id: $
--

insert into rhnSGTypeVirtSubLevel
values(lookup_sg_type('virtualization_host'),
       lookup_virt_sub_level('virtualization_free'),
       sysdate, sysdate);

insert into rhnSGTypeVirtSubLevel
values(lookup_sg_type('virtualization_host_platform'),
       lookup_virt_sub_level('virtualization_platform_free'),
       sysdate, sysdate);

commit;

