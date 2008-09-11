--
-- $Id$
--

create table rhnUserInfoPane (
    user_id number 
            constraint rhn_usr_info_pane_uid_nn not null
            constraint rhn_usr_info_pane_uid_fk 
                references web_contact(id)
                on delete cascade,
    pane_id number
            constraint rhn_usr_info_pane_pid_nn not null
            constraint rhn_usr_info_pane_pid_fk 
                references rhnInfoPane(id)
                on delete cascade
)
    storage ( freelists 16 )
    initrans 32;


create unique index rhnusrinfopane_uid_pid_uq
    on rhnUserInfoPane ( user_id, pane_id )
    tablespace [[4m_tbs]]
    storage ( pctincrease 1 freelists 16 )
    initrans 32;
