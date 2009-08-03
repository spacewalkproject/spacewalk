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


CREATE TABLE rhnProvisionState
(
    id           NUMBER NOT NULL
                     CONSTRAINT rhn_provstate_id_pk PRIMARY KEY,
    label        VARCHAR2(32) NOT NULL,
    description  VARCHAR2(256) NOT NULL,
    created      DATE
                     DEFAULT (sysdate) NOT NULL,
    modified     DATE
                     DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_provstate_l_id_idx
    ON rhnProvisionState (label, id)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE rhn_provstate_id_seq;

ALTER TABLE rhnProvisionState
    ADD CONSTRAINT rhn_provstate_l_uq UNIQUE (label);

