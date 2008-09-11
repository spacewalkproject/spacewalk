--
-- $Id: $
--

insert into rhnVirtSubLevel(id, label, name, created, modified)
values(rhn_virt_sl_seq.nextval, 'virtualization_free',
       'Virtualization free content group',
       sysdate, sysdate);

insert into rhnVirtSubLevel(id, label, name, created, modified)
values(rhn_virt_sl_seq.nextval, 'virtualization_platform_free',
       'Virtualization Platform free content group',
       sysdate, sysdate);


commit;



