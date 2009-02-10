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

--schedule_days current prod row count = 301
create table 
rhn_schedule_days
(
    recid               numeric   (12) not null
        constraint rhn_schdy_recid_ck check (recid > 0)
        constraint rhn_schdy_recid_pk primary key
--            using index tablespace [[2m_tbs]]
            ,
    schedule_id         numeric   (12)
			constraint rhn_schdy_sched_schedule_id_fk
        		references rhn_schedules( recid )
    			on delete cascade,
    ord                 numeric   (3),
    start_1             date,
    end_1               date,
    start_2             date,
    end_2               date,
    start_3             date,
    end_3               date,
    start_4             date,
    end_4               date,
    last_update_user    varchar (40),
    last_update_date    varchar (40)
)
  ;

comment on table rhn_schedule_days 
    is 'schdy  individual day records for schedules';

create index rhn_schdy_schedule_id_idx 
    on rhn_schedule_days ( schedule_id )
--    tablespace [[2m_tbs]]
  ;

create sequence rhn_schedule_days_recid_seq;

--
--Revision 1.2  2004/04/30 14:46:03  kja
--Moved foreign keys for non-circular references.
--
--Revision 1.1  2004/04/16 02:21:57  kja
--More monitoring schema.
--
--
--
--
--
