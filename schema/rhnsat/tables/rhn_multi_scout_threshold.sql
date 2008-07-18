--
--$Id$
--
--

--originally from the nolog instance
--multi_scout_threshold current prod row count = 188
create table 
rhn_multi_scout_threshold
(
    probe_id                         number   (12)
        constraint rhn_msthr_probe_id_nn not null
        constraint rhn_msthr_probe_id_pk primary key
            using index tablespace [[2m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    scout_warning_threshold_is_all   char     (1)  default '1'
        constraint rhn_msthr_warn_thres_nn not null,
    scout_crit_threshold_is_all      char     (1)  default '1'
        constraint rhn_msthr_crit_thres_nn not null,
    scout_warning_threshold          number   (12),
    scout_critical_threshold         number   (12)
)
    storage ( pctincrease 1 freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_multi_scout_threshold 
    is 'msthr  multi_scout_threshold definitions';

--$Log$
--Revision 1.2  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.1  2004/04/21 19:19:11  kja
--Added nolog tables.
--
