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


CREATE TABLE rhn_url_probe
(
    username                        VARCHAR2(40),
    password                        VARCHAR2(255),
    cookie_enabled                  CHAR(1)
                                        DEFAULT (0) NOT NULL,
    multi_step                      CHAR(1)
                                        DEFAULT (0) NOT NULL
                                        CONSTRAINT rhn_urlpb_multi_step_ck
                                            CHECK (multi_step in ( '0' , '1' )),
    run_on_scouts                   CHAR(1)
                                        DEFAULT ('1') NOT NULL
                                        CONSTRAINT rhn_urlpb_run_on_scouts_ck
                                            CHECK (run_on_scouts in ( '0' , '1' )),
    probe_id                        NUMBER NOT NULL
                                        CONSTRAINT rhn_urlpb_probe_id_pk PRIMARY KEY
                                        USING INDEX TABLESPACE [[2m_tbs]],
    probe_type                      VARCHAR2(12)
                                        DEFAULT ('url') NOT NULL
                                        CONSTRAINT rhn_urlpb_probe_type_ck
                                            CHECK (probe_type = 'url'),
    sat_cluster_id                  NUMBER,
    scout_warning_threshold_is_all  CHAR(1)
                                        DEFAULT ('1') NOT NULL,
    scout_crit_threshold_is_all     CHAR(1)
                                        DEFAULT ('1') NOT NULL,
    scout_warning_threshold         NUMBER
                                        DEFAULT (-1),
    scout_critical_threshold        NUMBER
                                        DEFAULT (-1)
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_url_probe IS 'urlpb  url probe';

CREATE INDEX rhn_url_probe_pid_ptype_idx
    ON rhn_url_probe (probe_id, probe_type);

ALTER TABLE rhn_url_probe
    ADD CONSTRAINT rhn_urlpb_probe_pr_id_pr_fk FOREIGN KEY (probe_id, probe_type)
    REFERENCES rhn_probe (recid, probe_type)
        ON DELETE CASCADE;

