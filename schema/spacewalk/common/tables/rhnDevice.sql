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


CREATE TABLE rhnDevice
(
    id           NUMBER NOT NULL
                     CONSTRAINT rhn_device_id_pk PRIMARY KEY
                     USING INDEX TABLESPACE [[32m_tbs]],
    server_id    NUMBER NOT NULL
                     CONSTRAINT rhn_device_sid_fk
                         REFERENCES rhnServer (id)
                         ON DELETE CASCADE,
    class        VARCHAR2(16),
    bus          VARCHAR2(16),
    detached     NUMBER,
    device       VARCHAR2(256),
    driver       VARCHAR2(256),
    description  VARCHAR2(256),
    pcitype      NUMBER
                     DEFAULT (-1),
    prop1        VARCHAR2(256),
    prop2        VARCHAR2(256),
    prop3        VARCHAR2(256),
    prop4        VARCHAR2(256),
    created      DATE
                     DEFAULT (sysdate) NOT NULL,
    modified     DATE
                     DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_device_server_id_idx
    ON rhnDevice (server_id)
    TABLESPACE [[32m_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_hw_dev_id_seq;

