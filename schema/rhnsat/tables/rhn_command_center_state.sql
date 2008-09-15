--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
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
    enable row movement
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
