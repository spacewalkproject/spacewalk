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

--schedule_weeks current prod row count = 0
create table 
rhn_schedule_weeks
(
    recid                   number   (12)
        constraint rhn_schwk_recid_nn not null
        constraint rhn_schwk_recid_ck check (recid > 0)
        constraint rhn_schwk_recid_pk primary key
            using index tablespace [[2m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    schedule_id             number   (12)
        constraint rhn_schwk_sched_id_nn not null,
    component_schedule_id   number   (12),
    ord                     number   (3),
    last_update_user        varchar2 (40),
    last_update_date        date
) 
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_schedule_weeks 
    is 'schwk  individual week records for schedules';

create index rhn_schwk_schedule_id_idx 
    on rhn_schedule_weeks ( schedule_id )
    tablespace [[2m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_schwk_comp_sched_id_idx 
    on rhn_schedule_weeks ( component_schedule_id )
    tablespace [[2m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_schedule_weeks
    add constraint rhn_schwk_sched_comp_sched_fk
    foreign key ( component_schedule_id )
    references rhn_schedules( recid );

alter table rhn_schedule_weeks
    add constraint rhn_schwk_sched_sched_id_fk
    foreign key ( schedule_id )
    references rhn_schedules( recid )
    on delete cascade;

create sequence rhn_schedule_weeks_recid_seq;

--$Log$
--Revision 1.4  2004/05/12 01:21:45  kja
--Added synonyms for the sequences.  Corrected some sequence names to start with
--rhn_.
--
--Revision 1.3  2004/05/07 23:30:22  kja
--Shortened constraint/other names as needed.  Fixed minor syntax errors.
--
--Revision 1.2  2004/04/30 14:46:03  kja
--Moved foreign keys for non-circular references.
--
--Revision 1.1  2004/04/16 19:51:57  kja
--More monitoring schema.
--
--
--$Id$
--
--
