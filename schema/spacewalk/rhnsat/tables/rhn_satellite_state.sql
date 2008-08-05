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

--originally from the nolog instance
--satellite_state current prod row count = 274

create table 
rhn_satellite_state
(
    satellite_id                     number   (12)
        constraint rhn_satst_sat_id_nn not null
        constraint rhn_satst_sat_id_pk primary key
            using index tablespace [[2m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    last_check                       date,
    probe_count                      number   (10),
    pct_ok                           number   (10,2),
    pct_warning                      number   (10,2),
    pct_critical                     number   (10,2),
    pct_unknown                      number   (10,2),
    pct_pending                      number   (10,2),
    recent_state_changes             number   (10),
    imminent_probes                  number   (10),
    max_exec_time                    number   (10,2),
    min_exec_time                    number   (10,2),
    avg_exec_time                    number   (10,2),
    max_latency                      number   (10,2),
    min_latency                      number   (10,2),
    avg_latency                      number   (10,2)
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_satellite_state 
    is 'satst  satellite state (monitoring)';

--$Log$
--Revision 1.2  2004/05/07 23:30:22  kja
--Shortened constraint/other names as needed.  Fixed minor syntax errors.
--
--Revision 1.1  2004/04/21 19:19:11  kja
--Added nolog tables.
--
