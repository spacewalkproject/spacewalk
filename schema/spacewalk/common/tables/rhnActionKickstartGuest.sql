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


CREATE TABLE rhnActionKickstartGuest
(
    id                   NUMBER NOT NULL,
    action_id            NUMBER NOT NULL
                             CONSTRAINT rhn_actionks_xenguest_aid_fk
                                 REFERENCES rhnAction (id)
                                 ON DELETE CASCADE,
    append_string        VARCHAR2(1024),
    ks_session_id        NUMBER
                             CONSTRAINT rhn_actionks_xenguest_ksid_fk
                                 REFERENCES rhnKickstartSession (id)
                                 ON DELETE CASCADE,
    guest_name           VARCHAR2(256),
    mem_kb               NUMBER,
    vcpus                NUMBER,
    disk_gb              NUMBER,
    cobbler_system_name  VARCHAR2(256),
    disk_path            VARCHAR2(256),
    virt_bridge          VARCHAR2(256),
    kickstart_host       VARCHAR2(256),
    created              DATE
                             DEFAULT (sysdate) NOT NULL,
    modified             DATE
                             DEFAULT (sysdate) NOT NULL,
    mac_address          VARCHAR2(17)
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_actionks_xenguest_aid_uq
    ON rhnActionKickstartGuest (action_id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_actionks_xenguest_id_idx
    ON rhnActionKickstartGuest (id)
    TABLESPACE [[4m_tbs]];

CREATE SEQUENCE rhn_actionks_xenguest_id_seq;

ALTER TABLE rhnActionKickstartGuest
    ADD CONSTRAINT rhn_actionks_xenguest_id_pk PRIMARY KEY (id);

