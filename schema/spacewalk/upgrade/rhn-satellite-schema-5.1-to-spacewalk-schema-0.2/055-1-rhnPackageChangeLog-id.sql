
alter table rhnPackageChangelog
add id              number;
alter table rhnPackageChangelog
modify id
        constraint rhn_pkg_cl_id_nn not null novalidate
        constraint rhn_pkg_cl_id_pk primary key
                using index tablespace [[64k_tbs]]
                novalidate;

