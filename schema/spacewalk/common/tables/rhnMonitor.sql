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


CREATE TABLE rhnMonitor
(
    batch_id     NUMBER NOT NULL,
    server_id    NUMBER NOT NULL
                     CONSTRAINT rhn_monitor_sid_fk
                         REFERENCES rhnServer (id)
                         ON DELETE CASCADE,
    probe_id     NUMBER NOT NULL,
    component    VARCHAR2(128),
    field        VARCHAR2(128),
    timestamp    DATE NOT NULL,
    granularity  NUMBER NOT NULL
                     CONSTRAINT rhn_monitor_granularity_fk
                         REFERENCES rhnMonitorGranularity (id),
    value        VARCHAR2(4000)
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_monitor_bid_idx
    ON rhnMonitor (batch_id)
    TABLESPACE [[8m_tbs]];

CREATE UNIQUE INDEX rhn_monitor_idx
    ON rhnMonitor (server_id, probe_id, granularity, timestamp, component, field)
    TABLESPACE [[8m_tbs]];

CREATE SEQUENCE rhn_monitor_bid_seq;

