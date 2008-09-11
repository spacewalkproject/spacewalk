--
--$Id$
--
--

--command_queue_sessions current prod row count = 9
create table 
rhn_command_queue_sessions
(
    contact_id          number   (12)
        constraint rhn_cqses_contact_id_nn not null,
    session_id          varchar2 (255),
    expiration_date     date,
    last_update_user    varchar2 (40),        
    last_update_date    date
)  
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_command_queue_sessions 
    is 'cqses  command queue sessions';

create unique index rhn_cqses_cid_uq
	on rhn_command_queue_sessions( contact_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

alter table rhn_command_queue_sessions
    add constraint rhn_cqses_cntct_contact_idfk
    foreign key ( contact_id )
    references web_contact( id );

--$Log$
--Revision 1.4  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.3  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
--
--$Id$
--
--
