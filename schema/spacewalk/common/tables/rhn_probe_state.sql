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


CREATE TABLE rhn_probe_state
(
    probe_id    NUMBER NOT NULL,
    scout_id    NUMBER NOT NULL,
    state       VARCHAR2(20),
    output      VARCHAR2(4000),
    last_check  DATE
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_probe_state IS 'prbst  probe state';

CREATE UNIQUE INDEX rhn_prbst_probe_id_scout_id_pk
    ON rhn_probe_state (probe_id, scout_id)
    TABLESPACE [[8m_tbs]];

ALTER TABLE rhn_probe_state
    ADD CONSTRAINT prbst_probe_id_scout_id_pk PRIMARY KEY (probe_id, scout_id);

