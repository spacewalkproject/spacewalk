--
--$Id$
--
--

--contact_groups current prod row count = 399
create table 
rhn_contact_groups
(  
    recid                   number   (12)
        constraint rhn_cntgp_recid_nn not null
        constraint rhn_cntgp_recid_notzero check (recid > 0)
        constraint rhn_cntgp_recid_pk primary key
            using index tablespace [[2m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    contact_group_name      varchar2 (30)
        constraint rhn_cntgp_group_name_nn not null,
    customer_id             number   (12)
        constraint rhn_cntgp_cust_id_nn not null,
    strategy_id             number   (12)
        constraint rhn_cntgp_strat_id_nn not null,
    ack_wait                number   (4)
        constraint rhn_cntgp_ack_wait_nn not null
        constraint rhn_cntgp_ack_wait_ck check ( ack_wait < 20160 ),
    rotate_first            char     (1)
        constraint rhn_cntgp_rotate_f_nn not null
        constraint rhn_cntgp_rotate_f_ck check (rotate_first in (0,1)),
    last_update_user        varchar2 (40)
        constraint rhn_cntgp_last_user_nn not null,
    last_update_date        date
        constraint rhn_cntgp_last_date_nn not null,
    notification_format_id  number   (12) default 4
        constraint rhn_cntgp_notif_fmt_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_contact_groups 
    is 'cntgp  contact group definitions';

create index rhn_cntgp_strategy_id_idx
    on rhn_contact_groups ( strategy_id )
    tablespace [[2m_tbs]]
    storage( pctincrease 1 freelists 16 )
    initrans 32;

create index rhn_cntgp_customer_id_idx
    on rhn_contact_groups ( customer_id )
    tablespace [[2m_tbs]]
    storage( pctincrease 1 freelists 16 )
    initrans 32;

alter table rhn_contact_groups
    add constraint rhn_cntgp_cstmr_customer_id_fk
    foreign key ( customer_id )
    references web_customer( id );

alter table rhn_contact_groups
    add constraint rhn_cntgp_strat_strategy_id_fk
    foreign key ( strategy_id )
    references rhn_strategies( recid );

alter table rhn_contact_groups
    add constraint rhn_ntfmt_cntgp_id_fk
    foreign key ( notification_format_id )
    references rhn_notification_formats( recid );

create sequence rhn_contact_groups_recid_seq;

--$Log$
--Revision 1.4  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.3  2004/05/12 01:21:45  kja
--Added synonyms for the sequences.  Corrected some sequence names to start with
--rhn_.
--
--Revision 1.2  2004/04/30 14:36:50  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.1  2004/04/13 16:40:33  kja
--Tweaked a bit of syntax on modified files.  Added more script files for
--monitoring schema.
--
--
--$Id$
--
--
