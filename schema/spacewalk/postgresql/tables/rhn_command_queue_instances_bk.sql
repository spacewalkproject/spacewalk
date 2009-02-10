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

--command_queue_instances_bk current prod row count = 21565
create table 
rhn_command_queue_instances_bk
(
    recid               numeric   (12) not null,
    command_id          numeric   (12) not null,
    notes               varchar (2000),
    date_submitted      timestamp not null,
    expiration_date     timestamp not null,
    notify_email        varchar (50),
    timeout             numeric   (5),
    last_update_user    varchar (40),
    last_update_date    timestamp
)
--    enable row movement
  ;
