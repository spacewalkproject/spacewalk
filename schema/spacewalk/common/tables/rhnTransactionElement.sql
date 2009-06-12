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


CREATE TABLE rhnTransactionElement
(
    transaction_id          NUMBER NOT NULL
                                CONSTRAINT rhn_transelem_tid_fk
                                    REFERENCES rhnTransaction (id)
                                    ON DELETE CASCADE,
    transaction_package_id  NUMBER NOT NULL
                                CONSTRAINT rhn_transelem_tpid_fk
                                    REFERENCES rhnTransactionPackage (id)
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_transelem_tid_tpid_uq
    ON rhnTransactionElement (transaction_id, transaction_package_id)
    TABLESPACE [[8m_tbs]];

