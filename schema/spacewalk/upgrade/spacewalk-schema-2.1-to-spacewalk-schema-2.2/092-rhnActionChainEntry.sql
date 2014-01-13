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

CREATE TABLE rhnActionChainEntry
(
    actionchain_id NUMBER NOT NULL
        CONSTRAINT rhn_actchainent_acid_fk
            REFERENCES rhnActionChain (id)
            ON DELETE CASCADE,
    action_id      NUMBER
        CONSTRAINT rhn_actchainent_aid_fk
            REFERENCES rhnAction (id)
            ON DELETE CASCADE,
    server_id      NUMBER NOT NULL
        CONSTRAINT rhn_actchainent_sid_fk
            REFERENCES rhnServer(id)
            ON DELETE CASCADE,
    sort_order     NUMBER NOT NULL,
    created        DATE DEFAULT(SYSDATE) NOT NULL,
    modified       DATE DEFAULT(SYSDATE) NOT NULL,

    CONSTRAINT rhn_actchainent_cid_sid_so_uq UNIQUE 
        (actionchain_id, server_id, sort_order)
    DEFERRABLE INITIALLY DEFERRED
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_actchainent_aid_uq
    ON rhnActionChainEntry(action_id)
    TABLESPACE [[64k_tbs]];
