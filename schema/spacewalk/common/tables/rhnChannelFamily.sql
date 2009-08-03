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


CREATE TABLE rhnChannelFamily
(
    id           NUMBER NOT NULL
                     CONSTRAINT rhn_channel_family_id_pk PRIMARY KEY
                     USING INDEX TABLESPACE [[64k_tbs]],
    org_id       NUMBER
                     CONSTRAINT rhn_channel_family_org_fk
                         REFERENCES web_customer (id)
                         ON DELETE CASCADE,
    name         VARCHAR2(128) NOT NULL,
    label        VARCHAR2(128) NOT NULL,
    product_url  VARCHAR2(128)
                     DEFAULT ('http://www.redhat.com/products/') NOT NULL,
    created      DATE
                     DEFAULT (sysdate) NOT NULL,
    modified     DATE
                     DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_channel_family_label_uq
    ON rhnChannelFamily (label)
    TABLESPACE [[64k_tbs]];

CREATE UNIQUE INDEX rhn_channel_family_name_uq
    ON rhnChannelFamily (name)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE rhn_channel_family_id_seq START WITH 1000;

