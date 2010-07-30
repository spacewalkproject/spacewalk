--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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


CREATE TABLE rhnKSData
(
    id              NUMBER NOT NULL
                        CONSTRAINT rhn_ks_id_pk PRIMARY KEY
                        USING INDEX TABLESPACE [[8m_tbs]],
    ks_type         VARCHAR2(8) NOT NULL,
    org_id          NUMBER NOT NULL
                        CONSTRAINT rhn_ks_oid_fk
                            REFERENCES web_customer (id)
                            ON DELETE CASCADE,
    is_org_default  CHAR(1)
                        DEFAULT ('N') NOT NULL
                        CONSTRAINT rhn_ks_default_ck
                            CHECK (is_org_default in ( 'Y' , 'N' )),
    label           VARCHAR2(64) NOT NULL,
    comments        VARCHAR2(4000),
    active          CHAR(1)
                        DEFAULT ('Y') NOT NULL
                        CONSTRAINT rhn_ks_active_ck
                            CHECK (active in ( 'Y' , 'N' )),
    postLog         CHAR(1)
                        DEFAULT ('N') NOT NULL
                        CONSTRAINT rhn_ks_post_log_ck
                            CHECK (postLog in ( 'Y' , 'N' )),
    preLog          CHAR(1)
                        DEFAULT ('N') NOT NULL
                        CONSTRAINT rhn_ks_pre_log_ck
                            CHECK (preLog in ( 'Y' , 'N' )),
    kscfg           CHAR(1)
                        DEFAULT ('N') NOT NULL
                        CONSTRAINT rhn_ks_cfg_save_ck
                            CHECK (kscfg in ( 'Y' , 'N' )),
    cobbler_id      VARCHAR2(64),
    pre             BLOB,
    post            BLOB,
    nochroot_post   BLOB,
    static_device   VARCHAR2(32),
    kernel_params   VARCHAR2(128),
    verboseup2date  CHAR(1)
                        DEFAULT ('N') NOT NULL
                        CONSTRAINT rhn_ks_verbose_up2date_ck
                            CHECK (verboseup2date in ( 'Y' , 'N' )),
    nonchrootpost   CHAR(1)
                        DEFAULT ('N') NOT NULL
                        CONSTRAINT rhn_ks_nonchroot_post_ck
                            CHECK (nonchrootpost in ( 'Y' , 'N' )),
    created         DATE
                        DEFAULT (sysdate) NOT NULL,
    modified        DATE
                        DEFAULT (sysdate) NOT NULL,
    CONSTRAINT rhn_ks_type_ck
        CHECK (ks_type in ( 'wizard' , 'raw' ))
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_ks_oid_label_id_idx
    ON rhnKSData (org_id, label, id)
    TABLESPACE [[8m_tbs]];

CREATE SEQUENCE rhn_ks_id_seq;

ALTER TABLE rhnKSData
    ADD CONSTRAINT rhn_ks_oid_label_uq UNIQUE (org_id, label);

