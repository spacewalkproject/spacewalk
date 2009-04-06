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


CREATE TABLE rhn_satellite_state
(
    satellite_id          NUMBER NOT NULL 
                              CONSTRAINT rhn_satst_sat_id_pk PRIMARY KEY 
                              USING INDEX TABLESPACE [[2m_tbs]], 
    last_check            DATE, 
    probe_count           NUMBER, 
    pct_ok                NUMBER, 
    pct_warning           NUMBER, 
    pct_critical          NUMBER, 
    pct_unknown           NUMBER, 
    pct_pending           NUMBER, 
    recent_state_changes  NUMBER, 
    imminent_probes       NUMBER, 
    max_exec_time         NUMBER, 
    min_exec_time         NUMBER, 
    avg_exec_time         NUMBER, 
    max_latency           NUMBER, 
    min_latency           NUMBER, 
    avg_latency           NUMBER
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_satellite_state IS 'satst  satellite state (monitoring)';

