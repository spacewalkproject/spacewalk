--
-- $Id$
--

create table
rhnServerCacheInfo
(
  server_id       number
                  constraint rhn_server_cache_info_sid_nn not null
                  constraint rhn_server_cache_info_sid_fk 
                     references rhnServer(id),
   update_time    date
)
        storage ( pctincrease 1 freelists 16 )
	enable row movement
        initrans 32;

create unique index rhn_server_cache_info_sid_idx
        on rhnServerCacheInfo(server_id)
        tablespace [[4m_tbs]]
        storage( pctincrease 1 freelists 16 )
        initrans 32;




-- $Log$
-- Revision 1.3  2005/02/09 21:23:07  jslagle
-- Initial sql files for rhnServerCacheInfo
--
-- Revision 1.2  2005/02/09 21:12:11  jslagle
-- Changed index to unique constraint
--

