--
--$Id$
--
--

--current_alerts current prod row count = 77868
create table 
rhn_current_alerts
(
    recid               number   (12)
        constraint rhn_alrts_recid_nn not null
        constraint rhn_alrts_recid_pk primary key
            using index tablespace [[128m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    date_submitted      date,
    last_server_change  date,
    date_completed      date    default to_date('31-12-9999', 'dd-mm-yyyy'),
    original_server     number   (12),
    current_server      number   (12),
    tel_args            varchar2 (2200),
    message             varchar2 (2000),
    ticket_id           varchar2 (80),
    destination_name    varchar2 (50),
    escalation_level    number   (2)    default 0,
    host_probe_id       number   (12),
    host_state          varchar2 (255),
    service_probe_id    number   (12),
    service_state       varchar2 (255),
    customer_id         number   (12)
        constraint rhn_alrts_cust_id_nn not null,
    netsaint_id         number   (12),
    probe_type          varchar2 (20)   default 'none',
    in_progress         char     (1)    default 1
        constraint rhn_alrts_in_prog_nn not null,
    last_update_date    date,
    event_timestamp     date
)
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_current_alerts 
    is 'alrts  current alert records';

create index rhn_alrts_service_probe_id_idx
    on rhn_current_alerts ( service_probe_id )
    tablespace [[128m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_alrts_current_server_idx
    on rhn_current_alerts ( current_server )  
    tablespace [[128m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_alrts_in_progress_idx
    on rhn_current_alerts ( in_progress ) 
    tablespace [[128m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_alrts_ticket_id_idx
    on rhn_current_alerts ( ticket_id )
    tablespace [[128m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_alrts_customer_id_idx
    on rhn_current_alerts ( customer_id )
    tablespace [[128m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_alrts_netsaint_id_idx
    on rhn_current_alerts ( netsaint_id )
    tablespace [[128m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_alrts_probe_type_idx
    on rhn_current_alerts ( probe_type )
    tablespace [[128m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_alrts_original_server_idx
    on rhn_current_alerts ( original_server )
    tablespace [[128m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_alrts_host_probe_id_idx
    on rhn_current_alerts ( host_probe_id )
    tablespace [[128m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create sequence rhn_current_alerts_recid_seq;

create or replace trigger 
rhn_current_alerts_mod_trig
before insert or update on rhn_current_alerts
referencing new as new old as old
for each row
declare
msg varchar2(200);
date_completed_is_null exception;
date_completed_is_not_null exception;

begin

    if :new.in_progress=0 and :new.date_completed is null
    then
        --- in_progress and date_completed are being updated simultaneously
        if ( updating( 'in_progress' ) and updating( 'date_completed') ) 
             or inserting
        then
            raise date_completed_is_null;
        elsif  updating( 'in_progress' )
        ---  date_completed is not being updated - so we can close the alert
        then
            :new.date_completed:=sysdate;
        else
        ---  date_completed is being updated - so we have to reopen alert
            :new.in_progress:=1;
        end if;
    elsif :new.in_progress=1 and :new.date_completed is not null
    then
    
        if ( updating( 'in_progress' ) and updating( 'date_completed') ) 
            or inserting
        --- in_progress and date_completed are being updated simultaneously
        then
            raise date_completed_is_not_null;
        elsif  updating( 'in_progress' )
        ---  date_completed is not being updated - so we can reopen the alert
        then
            :new.date_completed:=null;
        else
        ---  date_completed is being updated - so we have to close alert
            :new.in_progress:=0;
        end if;
    
    end if;
    
    exception
    when date_completed_is_null then
    msg:='date_completed is null while in_progress=0';
    raise_application_error (-20012,msg);
    when date_completed_is_not_null then
    msg:='date_completed is not null while in_progress=1';
    raise_application_error (-20012,msg);
    when others then
    raise;
end;
/
show errors

--$Log$
--Revision 1.4  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.3  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.2  2004/04/21 21:23:18  kja
--Added triggers.
--
--Revision 1.1  2004/04/13 16:40:33  kja
--Tweaked a bit of syntax on modified files.  Added more script files for
--monitoring schema.
--
