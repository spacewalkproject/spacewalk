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


CREATE TABLE rhnVirtSubLevel
(
    id        NUMBER
                  CONSTRAINT rhn_vsl_id_pk PRIMARY KEY,
    label     VARCHAR2(32) NOT NULL,
    name      VARCHAR2(128) NOT NULL,
    created   DATE
                  DEFAULT (sysdate) NOT NULL,
    modified  DATE
                  DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_vsl_label_id_name_idx
    ON rhnVirtSubLevel (label, id, name)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE rhn_virt_sl_seq;

