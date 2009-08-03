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


CREATE TABLE rhnMessage
(
    id            NUMBER NOT NULL
                      CONSTRAINT rhn_m_id_pk PRIMARY KEY
                      USING INDEX TABLESPACE [[64k_tbs]],
    message_type  NUMBER NOT NULL
                      CONSTRAINT rhn_m_mt_fk
                          REFERENCES rhnMessageType (id),
    priority      NUMBER
                      DEFAULT (0) NOT NULL
                      CONSTRAINT rhn_m_priority_fk
                          REFERENCES rhnMessagePriority (id),
    created       DATE
                      DEFAULT (sysdate) NOT NULL,
    modified      DATE
                      DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE SEQUENCE rhn_m_id_seq;

