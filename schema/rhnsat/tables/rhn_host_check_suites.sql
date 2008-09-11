--
--$Id$
--
--

--host_check_suites current prod row count = 4137
create table 
rhn_host_check_suites
(
    host_probe_id   number   (12)
        constraint rhn_hstck_host_probe_nn not null,
    suite_id        number   (12)
        constraint rhn_hstck_suite_id_nn not null
)
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_host_check_suites 
    is 'hstck  check suites used by hosts. the host_probe_id must reference a probe oftype hostprobe.';

create unique index rhn_hstck_suite_id_probe_id_pk 
    on rhn_host_check_suites ( host_probe_id , suite_id )
    tablespace [[2m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_host_check_suites 
    add constraint rhn_hstck_suite_id_probe_id_pk 
    primary key ( host_probe_id, suite_id );

alter table rhn_host_check_suites
    add constraint rhn_hstck_cksut_suite_id_fk
    foreign key ( suite_id )
    references rhn_check_suites( recid )
    on delete cascade;

alter table rhn_host_check_suites
    add constraint rhn_hstck_hstpb_probe_id_fk
    foreign key ( host_probe_id )
    references rhn_host_probe( probe_id )
    on delete cascade;

--$Log$
--Revision 1.3  2004/04/30 14:36:50  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.2  2004/04/13 20:45:55  kja
--Tweak constraint names to start with rhn_.
--
--Revision 1.1  2004/04/13 19:36:13  kja
--More monitoring schema.
--
--
--$Id$
--
--
