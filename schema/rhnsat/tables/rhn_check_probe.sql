--
--$Id$
--
--

--check_probe current prod row count = 26713
create table 
rhn_check_probe
(
    probe_id        number   (12)
        constraint rhn_chkpb_probe_id_nn not null
        constraint rhn_chkpb_probe_id_pk primary key
            using index tablespace [[4m_tbs]]
            storage( pctincrease 1 freelists 16 ),
    probe_type      varchar2 (12) default 'check' 
        constraint rhn_chk_probe_type_nn not null
        constraint chkpb_probe_type_ck 
            check (probe_type='check'),
    host_id         number   (12)
        constraint rhn_chk_host_id_nn not null,
    sat_cluster_id  number   (12)
        constraint rhn_chk_sat_cluster_id_nn not null
)
    storage ( pctincrease 1 freelists 16 )
    initrans 32;

comment on table rhn_check_probe 
    is 'CHKPB  Service check probe definitions (monitoring)';

create index rhn_chkpb_host_id_idx 
    on rhn_check_probe ( host_id )
    tablespace [[4m_tbs]]
    storage( pctincrease 1 freelists 16 )
    initrans 32;

create index rhn_chkpb_sat_cluster_id_idx
    on rhn_check_probe ( sat_cluster_id )
    tablespace [[4m_tbs]]
    storage( pctincrease 1 freelists 16 )
    initrans 32;

create unique index rhn_chkpb_pid_ptype_uq_idx
    on rhn_check_probe ( probe_id, probe_type )
    tablespace [[4m_tbs]]
    storage( pctincrease 1 freelists 16 )
    initrans 32;

alter table rhn_check_probe
    add constraint rhn_chkpb_host_id_fk
    foreign key ( host_id )
    references rhnServer( id );

alter table rhn_check_probe
    add constraint rhn_chkpb_recid_probe_typ_fk
    foreign key ( probe_id, probe_type )
    references rhn_probe( recid, probe_type )
    on delete cascade;

alter table rhn_check_probe
    add constraint rhn_chkpb_satcl_sat_cl_id_fk
    foreign key ( sat_cluster_id )
    references rhn_sat_cluster( recid )
    on delete cascade;

--$Log$
--Revision 1.7  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.6  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.5  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.4  2004/04/19 15:44:51  kja
--Adjustments from primary key audit.
--
--Revision 1.3  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
--Revision 1.2  2004/04/12 18:39:20  kja
--Added current production row count for each table as a comment to aid in
--sizing requirements.
--
--Revision 1.1  2004/04/08 22:52:31  kja
--Converting monitoring schema to rhn style -- a work in progress.
--
--$Id$
--
--
