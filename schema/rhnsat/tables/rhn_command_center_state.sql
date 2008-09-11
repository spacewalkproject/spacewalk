--
--$Id$
--
--

--command_center_state current prod row count = 1
create table 
rhn_command_center_state
(
    cust_admin_access_allowed char     (1)
        constraint rhn_cmdcs_allowed_nn not null,
    reason                    varchar2 (2000)
        constraint rhn_cmdcs_reason_nn not null,
    last_update_user          varchar2 (40)
        constraint rhn_cmdcs_last_user_nn not null,
    last_update_date          date
        constraint rhn_cmdcs_last_date_nn not null
) 
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_command_center_state 
    is 'CMDCS  State of the command center (monitoring)';

--$Log$
--Revision 1.2  2004/04/12 18:39:20  kja
--Added current production row count for each table as a comment to aid in
--sizing requirements.
--
--Revision 1.1  2004/04/08 22:52:31  kja
--Converting monitoring schema to rhn style -- a work in progress.
