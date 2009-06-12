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


CREATE TABLE rhnServerDMI
(
    id            NUMBER NOT NULL
                      CONSTRAINT rhn_server_dmi_pk PRIMARY KEY
                      USING INDEX TABLESPACE [[2m_tbs]],
    server_id     NUMBER NOT NULL
                      CONSTRAINT rhn_server_dmi_sid_fk
                          REFERENCES rhnServer (id),
    vendor        VARCHAR2(256),
    system        VARCHAR2(256),
    product       VARCHAR2(256),
    bios_vendor   VARCHAR2(256),
    bios_version  VARCHAR2(256),
    bios_release  VARCHAR2(256),
    asset         VARCHAR2(256),
    board         VARCHAR2(256),
    created       DATE
                      DEFAULT (sysdate) NOT NULL,
    modified      DATE
                      DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_server_dmi_sid_idx
    ON rhnServerDMI (server_id)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_server_dmi_id_seq;

