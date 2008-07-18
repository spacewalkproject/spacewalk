--
-- $Id$
--

create table
state_change
(
    o_id       varchar2(64)
    	       constraint state_change_o_id_nn not null,
    entry_time number
               constraint state_change_etime_nn not null,
    data       varchar2(4000)
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;
    
create index state_change_oid_entry_idx
    on state_change(o_id, entry_time)
    tablespace [[64k_tbs]]
    storage ( freelists 16 )
    initrans 32;
