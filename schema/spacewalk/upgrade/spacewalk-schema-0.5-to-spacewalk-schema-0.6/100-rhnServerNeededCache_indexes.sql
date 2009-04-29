-- rhn_snc_speid_idx index is also created during 0.4 -> 0.5 schema upgrades,
-- but is left out of the base 0.5 schema.

declare
	name_used exception;
	pragma exception_init(name_used, -00955);
begin
	execute immediate 'create index rhn_snc_speid_idx
		on rhnServerNeededCache(server_id, package_id, errata_id)
		noparallel
		tablespace [[128m_tbs]]
		nologging';
exception
	when name_used then
		execute immediate 'alter index rhn_snc_speid_idx noparallel';
end;
/

alter index rhn_snc_pid_idx noparallel;
alter index rhn_snc_sid_idx noparallel;
alter index rhn_snc_eid_idx noparallel;
