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
    satellite_id          NUMBER(12) NOT NULL
                              CONSTRAINT rhn_satst_sat_id_pk PRIMARY KEY
                              USING INDEX TABLESPACE [[2m_tbs]],
    last_check            DATE,
    probe_count           NUMBER(10),
    pct_ok                NUMBER(10,2),
    pct_warning           NUMBER(10,2),
    pct_critical          NUMBER(10,2),
    pct_unknown           NUMBER(10,2),
    pct_pending           NUMBER(10,2),
    recent_state_changes  NUMBER(10),
    imminent_probes       NUMBER(10),
    max_exec_time         NUMBER(10,2),
    min_exec_time         NUMBER(10,2),
    avg_exec_time         NUMBER(10,2),
    max_latency           NUMBER(10,2),
    min_latency           NUMBER(10,2),
    avg_latency           NUMBER(10,2)
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_satellite_state IS 'satst  satellite state (monitoring)';

