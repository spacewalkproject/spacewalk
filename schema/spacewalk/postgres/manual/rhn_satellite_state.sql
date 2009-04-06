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

--originally from the nolog instance
--satellite_state current prod row count = 274

create table 
rhn_satellite_state
(
    satellite_id                     numeric   (12) not null
  			      		constraint rhn_satst_sat_id_pk primary key
--            				using index tablespace [[2m_tbs]]
            ,
    last_check                       date,
    probe_count                      numeric   (10),
    pct_ok                           numeric   (10,2),
    pct_warning                      numeric   (10,2),
    pct_critical                     numeric   (10,2),
    pct_unknown                      numeric   (10,2),
    pct_pending                      numeric   (10,2),
    recent_state_changes             numeric   (10),
    imminent_probes                  numeric   (10),
    max_exec_time                    numeric   (10,2),
    min_exec_time                    numeric   (10,2),
    avg_exec_time                    numeric   (10,2),
    max_latency                      numeric   (10,2),
    min_latency                      numeric   (10,2),
    avg_latency                      numeric   (10,2)
)
  ;

comment on table rhn_satellite_state 
    is 'satst  satellite state (monitoring)';

--
--Revision 1.2  2004/05/07 23:30:22  kja
--Shortened constraint/other names as needed.  Fixed minor syntax errors.
--
--Revision 1.1  2004/04/21 19:19:11  kja
--Added nolog tables.
--
