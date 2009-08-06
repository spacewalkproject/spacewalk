
alter table rhnPackageChangelog
modify id 
	constraint rhn_pkg_cl_id_nn not null
	constraint rhn_pkg_cl_id_pk primary key
	using index tablespace [[64k_tbs]];

