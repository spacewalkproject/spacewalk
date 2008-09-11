--
-- $Id$
--

insert into rhnPackageSyncBlacklist (package_name_id)
	values (lookup_package_name('gpg-pubkey'));

insert into rhnPackageSyncBlacklist (package_name_id)
	values (lookup_package_name('rhns-ca-cert'));

insert into rhnPackageSyncBlacklist (package_name_id)
	values (lookup_package_name('rhn-org-trusted-ssl-cert'));

commit;

--
-- $Log$
-- Revision 1.1  2004/07/12 15:16:18  pjones
-- bugzilla: 126865 -- data for rhnPackageSyncBlacklist
--
