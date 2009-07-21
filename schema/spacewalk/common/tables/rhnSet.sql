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


CREATE TABLE rhnSet
(
    user_id        NUMBER NOT NULL
                       CONSTRAINT rhn_set_user_fk
                           REFERENCES web_contact (id)
                           ON DELETE CASCADE,
    label          VARCHAR2(32) NOT NULL,
    element        NUMBER,
    element_two    NUMBER,
    element_three  NUMBER,
    CONSTRAINT rhn_set_user_label_elem_unq UNIQUE (user_id, label, element, element_two, element_three)
        USING INDEX TABLESPACE [[8m_tbs]]
)
ENABLE ROW MOVEMENT
;

ALTER TABLE rhnSet
    NOLOGGING;

