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


CREATE TABLE rhnTransaction
(
    id            NUMBER NOT NULL, 
    server_id     NUMBER NOT NULL 
                      CONSTRAINT rhn_trans_sid_fk
                          REFERENCES rhnServer (id), 
    timestamp     DATE NOT NULL, 
    rpm_trans_id  NUMBER NOT NULL, 
    label         VARCHAR2(32), 
    created       DATE 
                      DEFAULT (sysdate) NOT NULL, 
    modified      DATE 
                      DEFAULT (sysdate) NOT NULL, 
    CONSTRAINT rhn_trans_sid_rti_unq UNIQUE (server_id, rpm_trans_id) 
        USING INDEX TABLESPACE [[8m_tbs]]
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_trans_id_sid_ts_rtid_idx
    ON rhnTransaction (id, server_id, timestamp, rpm_trans_id);

CREATE SEQUENCE rhn_transaction_id_seq;

ALTER TABLE rhnTransaction
    ADD CONSTRAINT rhn_trans_id_pk PRIMARY KEY (id) 
    USING INDEX TABLESPACE [[8m_tbs]];

