--
-- Copyright (c) 2008--2011 Red Hat, Inc.
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


CREATE TABLE rhnKickstartableTree
(
    id              NUMBER NOT NULL,
    org_id          NUMBER
                        CONSTRAINT rhn_kstree_oid_fk
                            REFERENCES web_customer (id)
                            ON DELETE CASCADE,
    label           VARCHAR2(64) NOT NULL,
    base_path       VARCHAR2(256) NOT NULL,
    channel_id      NUMBER NOT NULL
                        CONSTRAINT rhn_kstree_cid_fk
                            REFERENCES rhnChannel (id)
                            ON DELETE CASCADE,
    cobbler_id      VARCHAR2(64),
    cobbler_xen_id  VARCHAR2(64),
    boot_image      VARCHAR2(128)
                        DEFAULT ('spacewalk-koan'),
    kstree_type     NUMBER NOT NULL
                        CONSTRAINT rhn_kstree_kstreetype_fk
                            REFERENCES rhnKSTreeType (id),
    install_type    NUMBER NOT NULL
                        CONSTRAINT rhn_kstree_it_fk
                            REFERENCES rhnKSInstallType (id),
    last_modified   DATE
                        DEFAULT (sysdate) NOT NULL,
    created         DATE
                        DEFAULT (sysdate) NOT NULL,
    modified        DATE
                        DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_kstree_oid_label_uq
    ON rhnKickstartableTree (org_id, label)
    TABLESPACE [[8m_tbs]];

CREATE SEQUENCE rhn_kstree_id_seq;

ALTER TABLE rhnKickstartableTree
    ADD CONSTRAINT rhn_kstree_id_pk PRIMARY KEY (id)
    USING INDEX TABLESPACE [[4m_tbs]];

