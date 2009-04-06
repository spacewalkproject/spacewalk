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


CREATE TABLE rhnVirtualInstanceInfo
(
    name           VARCHAR2(128), 
    instance_id    NUMBER NOT NULL 
                       CONSTRAINT rhn_vii_viid_fk
                           REFERENCES rhnVirtualInstance (id) 
                           ON DELETE CASCADE, 
    instance_type  NUMBER NOT NULL 
                       CONSTRAINT rhn_vii_it_fk
                           REFERENCES rhnVirtualInstanceType (id), 
    memory_size_k  NUMBER, 
    vcpus          NUMBER, 
    state          NUMBER NOT NULL 
                       CONSTRAINT rhn_vii_state_fk
                           REFERENCES rhnVirtualInstanceState (id), 
    created        DATE 
                       DEFAULT (sysdate) NOT NULL, 
    modified       DATE 
                       DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_vii_viid_uq
    ON rhnVirtualInstanceInfo (instance_id)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE rhn_vii_id_seq;

