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


CREATE TABLE rhn_config_parameter
(
    group_name        VARCHAR2(255) NOT NULL,
    name              VARCHAR2(255) NOT NULL,
    value             VARCHAR2(255),
    security_type     VARCHAR2(255) NOT NULL,
    last_update_user  VARCHAR2(40),
    last_update_date  DATE
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_config_parameter IS 'confp  configuration parameter definition';

CREATE UNIQUE INDEX rhn_confp_group_name_name_pk
    ON rhn_config_parameter (group_name, name)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhn_config_parameter
    ADD CONSTRAINT rhn_confp_group_name_name_pk PRIMARY KEY (group_name, name);

ALTER TABLE rhn_config_parameter
    ADD CONSTRAINT rhn_confp_grpnm_group_name_fk FOREIGN KEY (group_name)
    REFERENCES rhn_config_group (name);

ALTER TABLE rhn_config_parameter
    ADD CONSTRAINT rhn_confp_scrty_sec_type_fk FOREIGN KEY (security_type)
    REFERENCES rhn_config_security_type (name);

