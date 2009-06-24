
alter table rhnPackage add sha256 VARCHAR(128)
CONSTRAINT rhn_package_sha256_nn not null;

show errors

