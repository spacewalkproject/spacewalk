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

--command_queue_execs_bk current prod row count = 75073
create table 
rhn_command_queue_execs_bk
(
    instance_id         numeric   (12) not null,
    netsaint_id         numeric   (12) not null,
    date_accepted       timestamp,
    date_executed       timestamp,
    exit_status         numeric   (5),
    execution_time      numeric   (10),
    stdout              varchar (4000),
    stderr              varchar (4000),
    last_update_date    timestamp,
    target_type         varchar (10) not null
)
--    enable row movement
  ;
