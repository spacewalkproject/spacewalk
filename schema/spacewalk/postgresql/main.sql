START TRANSACTION;

-- Avoid all the unnecessary NOTICE messages
set client_min_messages = error;

\i tables/dual.sql
\i tables/web_customer.sql
\i tables/rhnOrgQuota.sql
\i tables/rhnServerGroupType.sql
\i tables/rhnServerGroup.sql
\i tables/rhnUserGroup_sequences.sql
\i tables/rhnUserGroupType.sql
\i tables/rhnUserGroupType_data.sql
\i tables/rhnUserGroup.sql
\i tables/rhnSatelliteCert.sql

\i triggers/rhnOrgQuota.sql
\i triggers/rhnSatelliteCert.sql

\i procs/create_first_org.sql

COMMIT;
