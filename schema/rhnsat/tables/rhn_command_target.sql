--
--$Id$
--
--

--command_target current prod row count = 225
create table 
    rhn_command_target
(
    recid       number   (12)
        constraint rhn_cmdtg_recid_nn not null,
    target_type varchar2 (10)
        constraint rhn_cmdtg_target_ty_nn not null
        constraint cmdtg_target_type_ck check
            (target_type in ('cluster','node')),
    customer_id number   (12)
        constraint rhn_cmdtg_cust_id_nn not null
)
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_command_target 
    is 'cmdtg  command target (cluster or node)';

create unique index rhn_cmdtg_recid_pk 
    on rhn_command_target ( recid, target_type )
    tablespace [[2m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_command_target 
    add constraint rhn_cmdtg_recid_target_type_pk 
    primary key (recid, target_type);

create index rhn_cmdtg_cid_idx
	on rhn_command_target( customer_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

alter table rhn_command_target
    add constraint rhn_cmdtg_cstmr_customer_id_fk
    foreign key ( customer_id )
    references web_customer( id );

create sequence rhn_command_target_recid_seq;

--$Log$
--Revision 1.9  2004/07/28 23:18:36  dfaraldo
--Oops!  Undid previous change (putting target types back to lower-case).
--It's easier to modify the code to use lowercase than to modify the
--schema, static data, constraints, and dynamic data to use uppercase.
--
--Revision 1.8  2004/07/28 22:55:19  dfaraldo
--Changed check constraint to enforce upper-case command target types
--('CLUSTER' and 'NODE').
--
--Revision 1.7  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.6  2004/05/12 01:21:45  kja
--Added synonyms for the sequences.  Corrected some sequence names to start with
--rhn_.
--
--Revision 1.5  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.4  2004/04/16 22:10:00  kja
--Added missing sequences.
--
--Revision 1.3  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.2  2004/04/13 20:45:55  kja
--Tweak constraint names to start with rhn_.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
--
--$Id$
--
--
