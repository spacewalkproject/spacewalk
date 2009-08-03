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


CREATE TABLE rhn_command_queue_execs_bk
(
    instance_id       NUMBER(12) NOT NULL,
    netsaint_id       NUMBER(12) NOT NULL,
    date_accepted     DATE,
    date_executed     DATE,
    exit_status       NUMBER(5),
    execution_time    NUMBER(10),
    stdout            VARCHAR2(4000),
    stderr            VARCHAR2(4000),
    last_update_date  DATE,
    target_type       VARCHAR2(10) NOT NULL
)
ENABLE ROW MOVEMENT
;

