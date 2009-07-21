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


CREATE TABLE rhn_check_suite_probe
(
    probe_id        NUMBER(12) NOT NULL
                        CONSTRAINT rhn_ckspb_probe_id_pk PRIMARY KEY
                        USING INDEX TABLESPACE [[4m_tbs]],
    probe_type      VARCHAR2(12)
                        DEFAULT ('suite') NOT NULL
                        CONSTRAINT rhn_ckspb_probe_type_ck
                            CHECK (probe_type = 'suite'),
    check_suite_id  NUMBER(12) NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_check_suite_probe IS 'CKSPB  Check suite probe definitions (monitoring)';

CREATE INDEX rhn_ckspb_check_suite_id_idx
    ON rhn_check_suite_probe (check_suite_id)
    TABLESPACE [[4m_tbs]];

ALTER TABLE rhn_check_suite_probe
    ADD CONSTRAINT rhn_ckspb_cksut_ck_suite_id_fk FOREIGN KEY (check_suite_id)
    REFERENCES rhn_check_suites (recid)
        ON DELETE CASCADE;

