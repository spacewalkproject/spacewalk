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


CREATE TABLE rhn_host_check_suites
(
    host_probe_id  NUMBER(12) NOT NULL,
    suite_id       NUMBER(12) NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_host_check_suites IS 'hstck  check suites used by hosts. the host_probe_id must reference a probe oftype hostprobe.';

CREATE UNIQUE INDEX rhn_hstck_suite_id_probe_id_pk
    ON rhn_host_check_suites (host_probe_id, suite_id)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhn_host_check_suites
    ADD CONSTRAINT rhn_hstck_suite_id_probe_id_pk PRIMARY KEY (host_probe_id, suite_id);

ALTER TABLE rhn_host_check_suites
    ADD CONSTRAINT rhn_hstck_cksut_suite_id_fk FOREIGN KEY (suite_id)
    REFERENCES rhn_check_suites (recid)
        ON DELETE CASCADE;

ALTER TABLE rhn_host_check_suites
    ADD CONSTRAINT rhn_hstck_hstpb_probe_id_fk FOREIGN KEY (host_probe_id)
    REFERENCES rhn_host_probe (probe_id)
        ON DELETE CASCADE;

