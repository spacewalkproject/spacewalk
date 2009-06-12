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


CREATE TABLE rhnTransactionPackage
(
    id               NUMBER NOT NULL
                         CONSTRAINT rhn_transpack_id_pk PRIMARY KEY
                         USING INDEX TABLESPACE [[8m_tbs]],
    operation        NUMBER NOT NULL
                         CONSTRAINT rhn_transpack_op_fk
                             REFERENCES rhnTransactionOperation (id),
    name_id          NUMBER NOT NULL
                         CONSTRAINT rhn_transpack_nid_fk
                             REFERENCES rhnPackageName (id),
    evr_id           NUMBER NOT NULL
                         CONSTRAINT rhn_transpack_eid_fk
                             REFERENCES rhnPackageEVR (id),
    package_arch_id  NUMBER
                         CONSTRAINT rhn_transpack_paid_fk
                             REFERENCES rhnPackageArch (id)
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_transpack_onea_uq
    ON rhnTransactionPackage (operation, name_id, evr_id, package_arch_id)
    TABLESPACE [[8m_tbs]];

CREATE SEQUENCE rhn_transpack_id_seq;

