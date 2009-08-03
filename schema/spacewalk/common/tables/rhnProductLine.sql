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


CREATE TABLE rhnProductLine
(
    id             NUMBER NOT NULL,
    label          VARCHAR2(128) NOT NULL,
    name           VARCHAR2(128) NOT NULL,
    last_modified  DATE
                       DEFAULT (sysdate) NOT NULL,
    created        DATE
                       DEFAULT (sysdate) NOT NULL,
    modified       DATE
                       DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_prod_line_id_idx
    ON rhnProductLine (id)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_prod_line_label_idx
    ON rhnProductLine (label)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_prod_line_name_idx
    ON rhnProductLine (name)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE rhn_prod_line_id_seq START WITH 101;

ALTER TABLE rhnProductLine
    ADD CONSTRAINT rhn_prod_line_id_pk PRIMARY KEY (id);

ALTER TABLE rhnProductLine
    ADD CONSTRAINT rhn_prod_line_label_uq UNIQUE (label);

ALTER TABLE rhnProductLine
    ADD CONSTRAINT rhn_prod_line_name_uq UNIQUE (name);

