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
    recid               number   (12)
        constraint rhn_cqinsbk_recid_nn not null,
    command_id          number   (12)
        constraint rhn_cqinsbk_command_id_nn not null,
    notes               varchar2 (2000),
    date_submitted      date
        constraint rhn_cqinsbk_date_sub_nn not null,
    expiration_date     date
        constraint rhn_cqinsbk_exp_date_nn not null,
    notify_email        varchar2 (50),
    timeout             number   (5),
    last_update_user    varchar2 (40),
    last_update_date    date
)
    enable row movement
  ;

--
--Revision 1.2  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
