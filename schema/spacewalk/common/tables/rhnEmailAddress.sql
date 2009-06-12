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


CREATE TABLE rhnEmailAddress
(
    id           NUMBER NOT NULL,
    address      VARCHAR2(128) NOT NULL,
    user_id      NUMBER NOT NULL
                     CONSTRAINT rhn_eaddress_uid_fk
                         REFERENCES web_contact (id)
                         ON DELETE CASCADE,
    state_id     NUMBER NOT NULL
                     CONSTRAINT rhn_eaddress_sid_fk
                         REFERENCES rhnEmailAddressState (id),
    next_action  DATE,
    created      DATE
                     DEFAULT (sysdate) NOT NULL,
    modified     DATE
                     DEFAULT (sysdate) NOT NULL
)
TABLESPACE [[8m_data_tbs]]
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_eaddress_id_idx
    ON rhnEmailAddress (id)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_eaddress_uid_sid_addr_idx
    ON rhnEmailAddress (user_id, state_id, address)
    TABLESPACE [[8m_tbs]];

CREATE INDEX rhn_eaddress_niusa_idx
    ON rhnEmailAddress (next_action, id, user_id, state_id, address)
    TABLESPACE [[8m_tbs]];

CREATE SEQUENCE rhn_eaddress_id_seq;

ALTER TABLE rhnEmailAddress
    ADD CONSTRAINT rhn_eaddress_id_pk PRIMARY KEY (id);

ALTER TABLE rhnEmailAddress
    ADD CONSTRAINT rhn_eaddress_uid_sid_uq UNIQUE (user_id, state_id);

