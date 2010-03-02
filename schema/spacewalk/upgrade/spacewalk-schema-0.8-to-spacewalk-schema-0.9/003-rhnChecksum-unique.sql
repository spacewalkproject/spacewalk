declare
  index_not_exists exception;
  pragma exception_init(index_not_exists, -01418);
begin
  execute immediate 'drop index rhnChecksum_chsum_idx';
  execute immediate 'alter table rhnChecksum add constraint rhnChecksum_chsum_uq
          unique (checksum, checksum_type_id)
          using index tablespace [[32m_tbs]]';
exception
  when index_not_exists then
    null; -- index was already dropped
end;
/
