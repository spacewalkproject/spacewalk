drop index rhn_sat_node_sid_idx;
create unique index rhn_sat_node_sid_idx
on rhn_sat_node ( server_id )
   tablespace [[64k_tbs]]
   nologging
  ;

