ALTER TABLE rhnPackageFile RENAME COLUMN md5 TO checksum;
ALTER TABLE rhnPackageFile MODIFY checksum varchar(128);
/
show errors
