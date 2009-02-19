START TRANSACTION;

-- Avoid all the unnecessary NOTICE messages
set client_min_messages = warning;

/* special table; to be removed once we start using Orafce */
\i tables/dual.sql

/* tables go here */
\i tables/web_customer.sql
\i tables/rhnOrgQuota.sql
\i tables/rhnServerGroupType.sql
\i tables/rhnServerGroup.sql
\i tables/rhnUserGroup_sequences.sql
\i tables/rhnUserGroupType.sql
\i tables/rhnUserGroup.sql
\i tables/web_contact.sql
\i tables/rhnChannelFamily.sql 
\i tables/rhnPublicChannelFamily.sql 
\i tables/rhnPrivateChannelFamily.sql 
\i tables/rhnSatelliteCert.sql

/* triggers go here */
\i triggers/rhnOrgQuota.sql
\i triggers/rhnSatelliteCert.sql
\i triggers/web_contact.sql

/* functions go here */
\i procs/create_first_org.sql
\i procs/sequence_nextval.sql
\i procs/sequence_currval.sql
\i procs/lookup_package_key_type.sql
\i procs/create_pxt_session.sql
\i procs/truncateCacheQueue.sql
\i procs/lookup_cf_state.sql
\i procs/queue_errata.sql
\i procs/lookup_arch_type.sql
\i procs/lookup_feature_type.sql
\i procs/lookup_package_provider.sql
\i procs/delete_server_bulk.sql

/* Data population scripts go here */
\i tables/rhnUserGroupType_data.sql

/* packages go here */

/* views go here */
\i views/rhnOrgChannelFamilyPermissions.sql

commit;
