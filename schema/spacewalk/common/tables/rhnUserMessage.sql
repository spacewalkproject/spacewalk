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


CREATE TABLE rhnUserMessage
(
    user_id     NUMBER NOT NULL
                    CONSTRAINT rhn_um_user_id_fk
                        REFERENCES web_contact (id),
    message_id  NUMBER NOT NULL
                    CONSTRAINT rhn_um_message_id_fk
                        REFERENCES rhnMessage (id)
                        ON DELETE CASCADE,
    status      NUMBER NOT NULL
                    CONSTRAINT rhn_um_status_fk
                        REFERENCES rhnUserMessageStatus (id)
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_um_uid_mid_uq
    ON rhnUserMessage (user_id, message_id)
    TABLESPACE [[64k_tbs]];

