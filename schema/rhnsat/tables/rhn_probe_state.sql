--
--$Id$
--
--

--originally from the nolog instance
--probe_state current prod row count = 32615
create table rhn_probe_state
(
    probe_id                         number   (12)
        constraint rhn_prbst_probe_id_nn not null,
    scout_id                         number   (12)
        constraint rhn_prbst_scout_id_nn not null,
    state                            varchar2 (20),
    output                           varchar2 (4000),
    last_check                       date
) 
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_probe_state is 'prbst  probe state';

create unique index rhn_prbst_probe_id_scout_id_pk 
    on rhn_probe_state ( probe_id, scout_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_probe_state 
    add constraint prbst_probe_id_scout_id_pk 
    primary key ( probe_id, scout_id );

--$Log$
--Revision 1.2  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.1  2004/04/21 19:19:11  kja
--Added nolog tables.
--
