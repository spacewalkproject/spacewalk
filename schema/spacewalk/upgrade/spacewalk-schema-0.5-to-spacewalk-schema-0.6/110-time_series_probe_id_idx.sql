-- bugzilla 497477
-- we need function based index to lookup in that non-1st-NF o_id column

create index time_series_probe_id_idx
on time_series(SUBSTR(O_ID, INSTR(O_ID, '-') + 1,
 (INSTR(O_ID, '-', INSTR(O_ID, '-') + 1) - INSTR(O_ID, '-')) - 1
 ))
tablespace [[64k_tbs]]
nologging;

