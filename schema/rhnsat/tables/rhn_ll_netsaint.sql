--
--$Id$
--
--

--ll_netsaint current prod row count = 6
create table 
rhn_ll_netsaint
(
    netsaint_id number
        constraint rhn_llnet_netsaint_id_nn not null,
    city        varchar2 (255)
)
    storage ( pctincrease 1 freelists 16 )
    initrans 32;

comment on table rhn_ll_netsaint 
    is 'llnet  scout records';

alter table rhn_ll_netsaint
    add constraint rhn_llnts_sat_cluster_idfk
    foreign key ( netsaint_id )
    references rhn_sat_cluster( recid );

create index rhn_ll_ntsnts_nsid_idx
on rhn_ll_netsaint ( netsaint_id )
   tablespace [[64k_tbs]]
   nologging
   storage ( pctincrease 1 freelists 16 )
   initrans 32;

--$Log$
--Revision 1.2  2004/04/30 14:36:50  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.1  2004/04/13 19:36:13  kja
--More monitoring schema.
--
--
--$Id$
--
--
