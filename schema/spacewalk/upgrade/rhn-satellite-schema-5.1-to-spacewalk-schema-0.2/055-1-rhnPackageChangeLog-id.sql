
alter table rhnPackageChangelog
add id              number
        constraint rhn_pkg_cl_id_nn not null novalidate
        constraint rhn_pkg_cl_id_pk primary key
                using index tablespace [[64k_tbs]]
                novalidate;

