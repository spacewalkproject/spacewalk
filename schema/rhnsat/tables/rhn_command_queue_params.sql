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

--command_queue_params current prod row count = 3084
create table
rhn_command_queue_params
(
    instance_id     number   (12)
        constraint rhn_cqprm_instance_id_nn not null,
    ord             number   (3)
        constraint rhn_cqprm_ord_nn not null,
    value           varchar2 (1024)
)
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_command_queue_params 
    is 'cqprm   command queue parameter definitions';

create unique index rhn_cqprm_instance_id_ord_pk 
    on rhn_command_queue_params ( instance_id, ord )
    tablespace [[4m_tbs]]
    storage( pctincrease 1 freelists 16 )
    initrans 32;

alter table rhn_command_queue_params 
    add constraint rhn_cqprm_instance_id_ord_pk 
    primary key ( instance_id, ord );

alter table rhn_command_queue_params
    add constraint rhn_cqprm_cqins_instance_id_fk
    foreign key ( instance_id )
    references rhn_command_queue_instances( recid )
    on delete cascade;

--$Log$
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
--$Id$
--
--
