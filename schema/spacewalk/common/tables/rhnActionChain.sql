--
-- Copyright (c) 2014 SUSE
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
--
--

CREATE TABLE rhnActionChain
(
    id          NUMBER        NOT NULL PRIMARY KEY,
    label       VARCHAR2(256) NOT NULL,
    user_id     NUMBER        NOT NULL
                    CONSTRAINT rhn_actionchain_uid_fk
                        REFERENCES web_contact (id)
                        ON DELETE CASCADE,
    created     DATE          DEFAULT(SYSDATE) NOT NULL,
    modified    DATE          DEFAULT(SYSDATE) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE SEQUENCE rhn_actionchain_id_seq;
