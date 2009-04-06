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


CREATE TABLE rhnServerLocation
(
    id         NUMBER NOT NULL 
                   CONSTRAINT rhn_serverlocation_id_pk PRIMARY KEY 
                   USING INDEX TABLESPACE [[64k_tbs]], 
    server_id  NUMBER NOT NULL 
                   CONSTRAINT rhn_serverlocation_sid_fk
                       REFERENCES rhnServer (id), 
    machine    VARCHAR2(64), 
    rack       VARCHAR2(64), 
    room       VARCHAR2(32), 
    building   VARCHAR2(128), 
    address1   VARCHAR2(128), 
    address2   VARCHAR2(128), 
    city       VARCHAR2(128), 
    state      VARCHAR2(60), 
    country    CHAR(2), 
    created    DATE 
                   DEFAULT (sysdate) NOT NULL, 
    modified   DATE 
                   DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_serverlocation_sid_uq
    ON rhnServerLocation (server_id)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_server_loc_id_seq;

