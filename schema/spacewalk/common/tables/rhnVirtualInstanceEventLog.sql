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


CREATE TABLE rhnVirtualInstanceEventLog
(
    id                    NUMBER NOT NULL
                              CONSTRAINT rhn_viel_id_pk PRIMARY KEY
                              USING INDEX TABLESPACE [[64k_tbs]],
    virtual_instance_id   NUMBER
                              CONSTRAINT rhn_viel_vii_fk
                                  REFERENCES rhnVirtualInstance (id)
                                  ON DELETE CASCADE,
    event_type            NUMBER NOT NULL
                              CONSTRAINT rhn_viel_et_fk
                                  REFERENCES rhnVirtualInstanceEventType (id),
    event_metadata        VARCHAR2(4000),
    old_state             NUMBER NOT NULL
                              CONSTRAINT rhn_viel_old_state_fk
                                  REFERENCES rhnVirtualInstanceState (id),
    new_state             NUMBER NOT NULL
                              CONSTRAINT rhn_viel_new_state_fk
                                  REFERENCES rhnVirtualInstanceState (id),
    old_memory_size_k     NUMBER,
    new_memory_size_k     NUMBER,
    old_vcpus             NUMBER,
    new_vcpus             NUMBER,
    old_host_system_id    NUMBER,
    new_host_system_id    NUMBER,
    old_host_system_name  VARCHAR2(128),
    new_host_system_name  VARCHAR2(128),
    local_timestamp       DATE NOT NULL,
    created               DATE
                              DEFAULT (sysdate) NOT NULL,
    modified              DATE
                              DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_viel_vii_idx
    ON rhnVirtualInstanceEventLog (virtual_instance_id)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE rhn_viel_id_seq;

