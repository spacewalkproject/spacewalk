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


CREATE TABLE rhn_metrics
(
    metric_id         VARCHAR2(40) NOT NULL,
    storage_unit_id   VARCHAR2(10) NOT NULL,
    description       VARCHAR2(200),
    last_update_user  VARCHAR2(40),
    last_update_date  DATE,
    label             VARCHAR2(40),
    command_class     VARCHAR2(255)
                          DEFAULT ('nothing') NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_metrics IS 'metrc  metric definitions';

CREATE UNIQUE INDEX rhn_metrc_cmd_cl_met_id_pk
    ON rhn_metrics (command_class, metric_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_metrc_storage_unit_id_idx
    ON rhn_metrics (storage_unit_id)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhn_metrics
    ADD CONSTRAINT rhn_metrc_cmd_cl_metric_id_pk PRIMARY KEY (command_class, metric_id);

ALTER TABLE rhn_metrics
    ADD CONSTRAINT rhn_metrc_comcl_cmd_class_fk FOREIGN KEY (command_class)
    REFERENCES rhn_command_class (class_name);

ALTER TABLE rhn_metrics
    ADD CONSTRAINT rhn_metrc_uts_stor_ut_id_fk FOREIGN KEY (storage_unit_id)
    REFERENCES rhn_units (unit_id);

