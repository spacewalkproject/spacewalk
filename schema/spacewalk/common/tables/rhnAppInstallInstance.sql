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


CREATE TABLE rhnAppInstallInstance
(
    id        NUMBER NOT NULL,
    name      VARCHAR2(128) NOT NULL,
    label     VARCHAR2(128) NOT NULL,
    version   VARCHAR2(32) NOT NULL,
    created   DATE
                  DEFAULT (sysdate) NOT NULL,
    modified  DATE
                  DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_appinst_instance_id_idx
    ON rhnAppInstallInstance (id)
    TABLESPACE [[4m_tbs]];

CREATE INDEX rhn_appinst_instance_lv_id_idx
    ON rhnAppInstallInstance (label, version, id)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_appinst_instance_id_seq;

ALTER TABLE rhnAppInstallInstance
    ADD CONSTRAINT rhn_appinst_instance_id_pk PRIMARY KEY (id);

ALTER TABLE rhnAppInstallInstance
    ADD CONSTRAINT rhn_appinst_instance_lv_uq UNIQUE (label, version);

