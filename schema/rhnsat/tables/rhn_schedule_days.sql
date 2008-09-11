--
--$Id$
--
--

--schedule_days current prod row count = 301
create table 
rhn_schedule_days
(
    recid               number   (12)
        constraint rhn_schdy_recid_nn not null
        constraint rhn_schdy_recid_ck check (recid > 0)
        constraint rhn_schdy_recid_pk primary key
            using index tablespace [[2m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    schedule_id         number   (12),
    ord                 number   (3),
    start_1             date,
    end_1               date,
    start_2             date,
    end_2               date,
    start_3             date,
    end_3               date,
    start_4             date,
    end_4               date,
    last_update_user    varchar2 (40),
    last_update_date    varchar2 (40)
)
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_schedule_days 
    is 'schdy  individual day records for schedules';

create index rhn_schdy_schedule_id_idx 
    on rhn_schedule_days ( schedule_id )
    tablespace [[2m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_schedule_days
    add constraint rhn_schdy_sched_schedule_id_fk
    foreign key ( schedule_id )
    references rhn_schedules( recid )
    on delete cascade;

create sequence rhn_schedule_days_recid_seq;

--$Log$
--Revision 1.2  2004/04/30 14:46:03  kja
--Moved foreign keys for non-circular references.
--
--Revision 1.1  2004/04/16 02:21:57  kja
--More monitoring schema.
--
--
--$Id$
--
--
