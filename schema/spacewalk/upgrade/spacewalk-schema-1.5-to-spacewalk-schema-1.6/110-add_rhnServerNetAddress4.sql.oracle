--
-- Copyright (c) 2011 Red Hat, Inc.
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


CREATE TABLE rhnServerNetAddress4
(
    interface_id  NUMBER NOT NULL
                   CONSTRAINT rhn_srv_net_iaddress4_iid_fk
                       REFERENCES rhnServerNetInterface (id)
                       ON DELETE CASCADE,
    address    VARCHAR2(64),
    netmask    VARCHAR2(64),
    broadcast  VARCHAR2(64),
    created    DATE
                   DEFAULT (sysdate) NOT NULL,
    modified   DATE
                   DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_srv_net_addr4_iid_addr_idx
    ON rhnServerNetAddress4 (interface_id, address)
    TABLESPACE [[64k_tbs]];

ALTER TABLE rhnServerNetAddress4
    ADD CONSTRAINT rhn_srv_net_addr4_iid_addr_uq UNIQUE (interface_id, address);
