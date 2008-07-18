--
--$Id$
--
--

--originally from the nolog instance
--satellite_state current prod row count = 274

create table 
rhn_satellite_state
(
    satellite_id                     number   (12)
        constraint rhn_satst_sat_id_nn not null
        constraint rhn_satst_sat_id_pk primary key
            using index tablespace [[2m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    last_check                       date,
    probe_count                      number   (10),
    pct_ok                           number   (10,2),
    pct_warning                      number   (10,2),
    pct_critical                     number   (10,2),
    pct_unknown                      number   (10,2),
    pct_pending                      number   (10,2),
    recent_state_changes             number   (10),
    imminent_probes                  number   (10),
    max_exec_time                    number   (10,2),
    min_exec_time                    number   (10,2),
    avg_exec_time                    number   (10,2),
    max_latency                      number   (10,2),
    min_latency                      number   (10,2),
    avg_latency                      number   (10,2)
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_satellite_state 
    is 'satst  satellite state (monitoring)';

--$Log$
--Revision 1.2  2004/05/07 23:30:22  kja
--Shortened constraint/other names as needed.  Fixed minor syntax errors.
--
--Revision 1.1  2004/04/21 19:19:11  kja
--Added nolog tables.
--
