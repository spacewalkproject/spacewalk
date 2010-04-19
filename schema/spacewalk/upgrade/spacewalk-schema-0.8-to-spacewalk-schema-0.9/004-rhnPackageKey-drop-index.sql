alter table rhnPackageKeyAssociation disable constraint rhn_pkeya_kid_fk;
alter table rhnPackageKey disable constraint rhn_pkey_id_pk;
drop index rhn_pkey_id_k_pid_idx;
alter table rhnPackageKey enable constraint rhn_pkey_id_pk;
alter table rhnPackageKeyAssociation enable constraint rhn_pkeya_kid_fk;
