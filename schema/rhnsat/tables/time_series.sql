--
-- $Id$
--

create table
time_series
(
    o_id       varchar2(64)
    	       constraint time_series_o_id_nn not null,
    entry_time number
               constraint time_series_etime_nn not null,
    data       varchar2(1024)
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;
    
create index time_series_oid_entry_idx
    on time_series(o_id, entry_time)
    tablespace [[64k_tbs]]
    storage ( freelists 16 )
    initrans 32;
