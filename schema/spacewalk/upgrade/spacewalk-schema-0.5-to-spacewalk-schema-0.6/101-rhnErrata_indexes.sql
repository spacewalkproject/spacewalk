create index rhn_errata_udate_index
	on rhnErrata( update_date )
	tablespace [[64k_tbs]]
  ;
	
create index rhn_errata_syn_index
	on rhnErrata( synopsis )
	tablespace [[64k_tbs]]
  ;
	
