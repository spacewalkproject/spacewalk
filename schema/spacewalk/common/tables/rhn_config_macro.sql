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


CREATE TABLE rhn_config_macro
(
    name              VARCHAR2(255) NOT NULL,
    definition        VARCHAR2(255),
    description       VARCHAR2(255),
    editable          CHAR(1)
                          DEFAULT (0) NOT NULL,
    last_update_user  VARCHAR2(40),
    last_update_date  DATE
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_config_macro IS 'confm configuration macro def';

CREATE UNIQUE INDEX rhn_confm_name_pk
    ON rhn_config_macro (name)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhn_config_macro
    ADD CONSTRAINT rhn_confm_name_pk PRIMARY KEY (name);


