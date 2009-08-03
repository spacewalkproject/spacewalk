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


CREATE TABLE rhnGrailComponentChoices
(
    user_id         NUMBER NOT NULL
                        CONSTRAINT rhn_grail_comp_ch_user_fk
                            REFERENCES web_contact (id)
                            ON DELETE CASCADE,
    ordering        NUMBER NOT NULL,
    component_pkg   VARCHAR2(64) NOT NULL,
    component_mode  VARCHAR2(64) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_grail_comp_ch_user_ord_uq
    ON rhnGrailComponentChoices (user_id, ordering)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_grail_cmp_ch_user
    ON rhnGrailComponentChoices (user_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

