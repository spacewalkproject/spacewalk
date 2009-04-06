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


CREATE TABLE rhnServerGroupNotes
(
    id               NUMBER NOT NULL 
                         CONSTRAINT rhn_servergrp_note_id_pk PRIMARY KEY 
                         USING INDEX TABLESPACE [[64k_tbs]], 
    creator          NUMBER 
                         CONSTRAINT rhn_servergrp_note_creator_fk
                             REFERENCES web_contact (id) 
                             ON DELETE SET NULL, 
    server_group_id  NUMBER NOT NULL 
                         CONSTRAINT rhn_servergrp_note_fk
                             REFERENCES rhnServerGroup (id) 
                             ON DELETE CASCADE, 
    subject          VARCHAR2(80) NOT NULL, 
    note             VARCHAR2(4000) NOT NULL, 
    created          DATE 
                         DEFAULT (sysdate) NOT NULL, 
    modified         DATE 
                         DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_servergrp_note_srvr_id_idx
    ON rhnServerGroupNotes (server_group_id)
    TABLESPACE [[64k_tbs]]
    LOGGING;

CREATE INDEX rhn_servergrp_note_creator_idx
    ON rhnServerGroupNotes (creator)
    TABLESPACE [[64k_tbs]]
    LOGGING;

CREATE SEQUENCE rhn_servergrp_note_id_seq;

