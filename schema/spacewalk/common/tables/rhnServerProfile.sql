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


CREATE TABLE rhnServerProfile
(
    id               NUMBER NOT NULL,
    org_id           NUMBER NOT NULL
                         CONSTRAINT rhn_server_profile_oid_fk
                             REFERENCES web_customer (id)
                             ON DELETE CASCADE,
    base_channel     NUMBER NOT NULL
                         CONSTRAINT rhn_server_profile_bcid_fk
                             REFERENCES rhnChannel (id),
    name             VARCHAR2(128),
    description      VARCHAR2(256),
    info             VARCHAR2(128),
    profile_type_id  NUMBER NOT NULL
                         CONSTRAINT rhn_server_profile_ptype_fk
                             REFERENCES rhnServerProfileType (id),
    created          DATE
                         DEFAULT (sysdate) NOT NULL,
    modified         DATE
                         DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_server_profile_noid_uq
    ON rhnServerProfile (org_id, name)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_sprofile_id_oid_bc_idx
    ON rhnServerProfile (id, org_id, base_channel)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_server_profile_o_id_bc_idx
    ON rhnServerProfile (org_id, id, base_channel)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE INDEX rhn_server_profile_bc_idx
    ON rhnServerProfile (base_channel)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_server_profile_id_seq;

ALTER TABLE rhnServerProfile
    ADD CONSTRAINT rhn_server_profile_id_pk PRIMARY KEY (id);

