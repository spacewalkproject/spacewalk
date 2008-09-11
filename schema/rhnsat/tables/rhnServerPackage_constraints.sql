alter table rhnServerPackage modify server_id
	constraint rhn_serverpackage_sid_nn not null;

alter table rhnServerPackage modify name_id
	constraint rhn_serverpackage_nid_nn not null;

alter table rhnServerPackage modify evr_id
	constraint rhn_serverpackage_eid_nn not null;

alter table rhnServerPackage
	add constraint rhn_serverpackage_sid_fk
	foreign key (server_id) references rhnServer(id) on delete cascade;

alter table rhnServerPackage
	add constraint rhn_serverpackage_nid_fk
	foreign key (name_id) references rhnPackageName(id);

alter table rhnServerPackage
	add constraint rhn_serverpackage_eid_fk
	foreign key (evr_id) references rhnPackageEVR(id);

alter table rhnServerPackage
   add constraint rhn_serverpackage_paid_fk
   foreign key (package_arch_id) references rhnPackageArch(id);
