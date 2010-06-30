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


CREATE TABLE rhnChannel
(
    id                  NUMBER NOT NULL
                            CONSTRAINT rhn_channel_id_pk PRIMARY KEY
                            USING INDEX TABLESPACE [[64k_tbs]],
    parent_channel      NUMBER
                            CONSTRAINT rhn_channel_parent_ch_fk
                                REFERENCES rhnChannel (id),
    org_id              NUMBER
                            CONSTRAINT rhn_channel_org_fk
                                REFERENCES web_customer (id),
    channel_arch_id     NUMBER NOT NULL
                            CONSTRAINT rhn_channel_caid_fk
                                REFERENCES rhnChannelArch (id),
    label               VARCHAR2(128) NOT NULL,
    basedir             VARCHAR2(256) NOT NULL,
    name                VARCHAR2(256) NOT NULL,
    summary             VARCHAR2(500) NOT NULL,
    description         VARCHAR2(4000),
    product_name_id     NUMBER
                            CONSTRAINT rhn_channel_product_name_ch_fk
                                REFERENCES rhnProductName (id),
    gpg_key_url         VARCHAR2(256),
    gpg_key_id          VARCHAR2(14),
    gpg_key_fp          VARCHAR2(50),
    end_of_life         DATE,
    checksum_type_id    NUMBER CONSTRAINT rhn_channel_checksum_fk
                                REFERENCES rhnChecksumType(id),
    receiving_updates   CHAR(1)
                            DEFAULT ('Y') NOT NULL
                            CONSTRAINT rhn_channel_ru_ck
                                CHECK (receiving_updates in ( 'Y' , 'N' )),
    last_modified       DATE
                            DEFAULT (sysdate) NOT NULL,
    last_synced         DATE,
    channel_product_id  NUMBER
                            CONSTRAINT rhn_channel_cpid_fk
                                REFERENCES rhnChannelProduct (id),
    channel_access      VARCHAR2(10)
                            DEFAULT ('private'),
    maint_name          VARCHAR2(128),
    maint_email         VARCHAR2(128),
    maint_phone         VARCHAR2(128),
    support_policy      VARCHAR2(256),
    created             DATE
                            DEFAULT (sysdate) NOT NULL,
    modified            DATE
                            DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_channel_label_uq
    ON rhnChannel (label)
    TABLESPACE [[64k_tbs]];

CREATE UNIQUE INDEX rhn_channel_name_uq
    ON rhnChannel (name)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_channel_org_idx
    ON rhnChannel (org_id, id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE INDEX rhn_channel_url_id_idx
    ON rhnChannel (label, id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE INDEX rhn_channel_parent_id_idx
    ON rhnChannel (parent_channel, id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE INDEX rhn_channel_access_idx
    ON rhnChannel (channel_access)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_channel_id_seq START WITH 101;

