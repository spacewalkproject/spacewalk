
alter table rhnPackageChangelog
modify
	constraint rhn_pkg_cl_id_nn validate;
alter table rhnPackageChangelog
modify
	constraint rhn_pkg_cl_id_pk validate;

