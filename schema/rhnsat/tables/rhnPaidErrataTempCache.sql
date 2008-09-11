create global temporary table rhnPaidErrataTempCache
(
  errata_id number,
  user_id number,
  server_id number
) on commit preserve rows;

create index rhnpec_u_idx on rhnPaidErrataTempCache(user_id);

