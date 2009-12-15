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


CREATE TABLE rhn_contact_group_members
(
    contact_group_id          NUMBER NOT NULL
                                  CONSTRAINT rhn_cntgm_cgid_fk
                                      REFERENCES rhn_contact_groups (recid)
                                      ON DELETE CASCADE,
    order_number              NUMBER NOT NULL,
    member_contact_method_id  NUMBER
                                  CONSTRAINT rhn_cntgm_mcmid_fk
                                      REFERENCES rhn_contact_methods (recid)
                                      ON DELETE CASCADE,
    member_contact_group_id   NUMBER
                                  CONSTRAINT rhn_cntgm_mcgid_fk
                                      REFERENCES rhn_contact_groups (recid)
                                      ON DELETE CASCADE,
    last_update_user          VARCHAR2(40) NOT NULL,
    last_update_date          DATE NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_contact_group_members IS 'cntgm  contact group membership records';

CREATE INDEX rhn_cntgm_cgid_order_idx
    ON rhn_contact_group_members (contact_group_id, order_number)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_cntgm_mcmid_idx
    ON rhn_contact_group_members (member_contact_method_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_cntgm_mcgid_idx
    ON rhn_contact_group_members (member_contact_group_id)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhn_contact_group_members
    ADD CONSTRAINT rhn_cntgm_cgid_order_pk PRIMARY KEY (contact_group_id, order_number);

