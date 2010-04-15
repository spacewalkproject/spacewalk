
insert into rhnKSInstallType (id, label, name) values (rhn_ksinstalltype_id_seq.nextval, 'fedora', 'Fedora');

update rhnKickstartableTree K set K.INSTALL_TYPE = (select id from rhnKSInstallType where label = 'fedora') where K.INSTALL_TYPE in (select id from rhnKSInstallType where label like '%fedora%');

delete from rhnKSInstallType where label = 'fedora_8';
delete from rhnKSInstallType where label = 'fedora_9';
delete from rhnKSInstallType where label = 'fedora_10';





