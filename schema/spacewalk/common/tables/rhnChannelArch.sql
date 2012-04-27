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


CREATE TABLE rhnChannelArch
(
    id            NUMBER NOT NULL,
    label         VARCHAR2(64) NOT NULL,
    arch_type_id  NUMBER NOT NULL
                      CONSTRAINT rhn_carch_atid_fk
                          REFERENCES rhnArchType (id),
    name          VARCHAR2(64) NOT NULL,
    created       DATE
                      DEFAULT (sysdate) NOT NULL,
    modified      DATE
                      DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE SEQUENCE rhn_channel_arch_id_seq START WITH 500;

ALTER TABLE rhnChannelArch
    ADD CONSTRAINT rhn_carch_id_pk PRIMARY KEY (id);

ALTER TABLE rhnChannelArch
    ADD CONSTRAINT rhn_carch_label_uq UNIQUE (label)
    USING INDEX TABLESPACE [[2m_tbs]];

ALTER TABLE rhnChannelArch
    ADD CONSTRAINT rhn_carch_name_uq UNIQUE (name)
    USING INDEX TABLESPACE [[2m_tbs]];
