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

--command_queue_params current prod row count = 3084
create table
rhn_command_queue_params
(
    instance_id     numeric   (12) not null,
    ord             numeric   (3) not null,
    value           varchar (1024),
    constraint rhn_cqprm_instance_id_ord_pk primary key ( instance_id, ord ),
    constraint rhn_cqprm_cqins_instance_id_fk foreign key ( instance_id ) references rhn_command_queue_instances( recid )
    on delete cascade
)

  ;

comment on table rhn_command_queue_params 
    is 'cqprm   command queue parameter definitions';



--
--Revision 1.3  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.2  2004/04/13 20:45:55  kja
--Tweak constraint names to start with rhn_.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
--
--
--
--
