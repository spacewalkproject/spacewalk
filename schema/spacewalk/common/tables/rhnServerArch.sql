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


CREATE TABLE rhnServerArch
(
    id            NUMBER NOT NULL, 
    label         VARCHAR2(64) NOT NULL, 
    name          VARCHAR2(64) NOT NULL, 
    arch_type_id  NUMBER NOT NULL 
                      CONSTRAINT rhn_sarch_atid_fk
                          REFERENCES rhnArchType (id), 
    created       DATE 
                      DEFAULT (sysdate) NOT NULL, 
    modified      DATE 
                      DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_sarch_id_l_n_idx
    ON rhnServerArch (id, label, name)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_sarch_l_id_n_idx
    ON rhnServerArch (label, id, name)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_server_arch_id_seq START WITH 1000;

ALTER TABLE rhnServerArch
    ADD CONSTRAINT rhn_sarch_id_pk PRIMARY KEY (id);

ALTER TABLE rhnServerArch
    ADD CONSTRAINT rhn_sarch_label_uq UNIQUE (label);

