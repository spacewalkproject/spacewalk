--
--$Id$
--
--

--probe current prod row count = 34038
create table 
rhn_probe
(
    recid                            number   (12)
        constraint rhn_probe_recid_nn not null
        constraint rhn_probe_recid_pk primary key
            using index tablespace [[8m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    probe_type                       varchar2 (15)
        constraint rhn_probe_probe_type_nn not null,
    description                      varchar2 (255)
	constraint rhn_probe_description_nn not null,
    customer_id                      number   (12)
        constraint rhn_probe_cust_id_nn not null,
    command_id                       number   (16)
        constraint rhn_probe_command_id_nn not null,
    contact_group_id                 number   (12),
    notify_critical                  char     (1),
    notify_warning                   char     (1),
    notify_unknown                   char     (1),
    notify_recovery                  char     (1),
    notification_interval_minutes    number   (16)
        constraint rhn_probe_notif_int_nn not null,
    check_interval_minutes           number   (16)
        constraint rhn_probe_chk_int_nn not null,
    retry_interval_minutes           number   (16)
        constraint rhn_probe_retry_int_nn not null,
    max_attempts                     number   (16),
    last_update_user                 varchar2 (40),
    last_update_date                 date
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_probe 
    is 'probe  probe definitions';

create unique index rhn_probe_recid_probe_type_uq 
    on rhn_probe ( recid, probe_type )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_probe_check_command_id_idx 
    on rhn_probe ( command_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_probe_customer_id_idx 
    on rhn_probe ( customer_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_probe_probe_type_idx 
    on rhn_probe ( probe_type )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_probe_contact_grp_idx 
    on rhn_probe ( contact_group_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_probe 
    add constraint rhn_probe_recid_probe_type_uq 
    unique ( recid, probe_type );

alter table rhn_probe
    add constraint rhn_probe_cmmnd_command_id_fk
    foreign key ( command_id )
    references rhn_command( recid );

alter table rhn_probe
    add constraint rhn_probe_cstmr_customer_id_fk
    foreign key ( customer_id )
    references web_customer( id );

alter table rhn_probe
    add constraint rhn_probe_prbtp_probe_type_fk
    foreign key ( probe_type )
    references rhn_probe_types( probe_type );

create sequence rhn_probes_recid_seq;

--$Log$
--Revision 1.6  2004/07/13 14:13:23  kja
--bugzilla 127588 -- create index on rhn_probe (contact_group_id) to prevent
--full table scan of rhn_probe.
--
--Revision 1.5  2004/06/25 21:42:26  nhansen
--bug 126752: make rhn_probe.description a not null field in the db, since the UI has it as a mandatory param
--
--Revision 1.4  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.3  2004/04/30 14:36:51  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.2  2004/04/16 02:21:16  kja
--Corrected index naming.  Removed a bkup table.
--
--Revision 1.1  2004/04/13 22:05:17  kja
--More monitoring schema.
--
--
--$Id$
--
--
