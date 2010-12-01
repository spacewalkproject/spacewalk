
insert into rhnKSInstallType (id, label, name) values (rhn_ksinstalltype_id_seq.nextval, 'fedora', 'Fedora');

-- 650129: we need to disable the trigger to prevent it from automatically
-- updating rhnKickstartableTree.last_modified values
alter trigger rhn_kstree_mod_trig disable;

update rhnKickstartableTree K set K.INSTALL_TYPE = (select id from rhnKSInstallType where label = 'fedora') where K.INSTALL_TYPE in (select id from rhnKSInstallType where label like '%fedora%');

-- we need to enable the trigger again
alter trigger rhn_kstree_mod_trig enable;

delete from rhnKSInstallType where label = 'fedora_8';
delete from rhnKSInstallType where label = 'fedora_9';
delete from rhnKSInstallType where label = 'fedora_10';
