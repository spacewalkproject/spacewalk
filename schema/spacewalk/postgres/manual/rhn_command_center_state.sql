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
--
--
--

--command_center_state current prod row count = 1
create table 
rhn_command_center_state
(
-- TODO: should cust_admin_access_allowed be a boolean i.e Y/N?
    cust_admin_access_allowed char     (1) not null,
    reason                    varchar (2000) not null,
    last_update_user          varchar (40) not null,
    last_update_date          timestamp not null
) 
--    enable row movement
  ;

--comment on table rhn_command_center_state is 'CMDCS  State of the command center (monitoring)';
