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


CREATE TABLE rhnInfoPane
(
    id     NUMBER 
               CONSTRAINT rhn_info_pane_id_pk PRIMARY KEY, 
    label  VARCHAR2(64) NOT NULL, 
    acl    VARCHAR2(4000)
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_info_pane_labl_uq
    ON rhnInfoPane (label)
    TABLESPACE [[4m_tbs]];

CREATE SEQUENCE rhn_info_pane_id_seq;

