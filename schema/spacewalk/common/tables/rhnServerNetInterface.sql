--
-- Copyright (c) 2008 -- 2011 Red Hat, Inc.
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


CREATE TABLE rhnServerNetInterface
(
    id         NUMBER NOT NULL
                   CONSTRAINT rhn_srv_net_iface_id_pk PRIMARY KEY
                       USING INDEX TABLESPACE [[4m_tbs]],
    server_id  NUMBER NOT NULL
                   CONSTRAINT rhn_srv_net_iface_sid_fk
                       REFERENCES rhnServer (id),
    name       VARCHAR2(32) NOT NULL,
    hw_addr    VARCHAR2(18),
    module     VARCHAR2(128),
    is_primary VARCHAR2(1),
    created    timestamp with local time zone
                   DEFAULT (current_timestamp) NOT NULL,
    modified   timestamp with local time zone
                   DEFAULT (current_timestamp) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_srv_net_iface_sid_name_idx
    ON rhnServerNetInterface (server_id, name)
    TABLESPACE [[8m_tbs]];

ALTER TABLE rhnServerNetInterface
    ADD CONSTRAINT rhn_srv_net_iface_sid_name_uq UNIQUE (server_id, name);

CREATE SEQUENCE rhn_srv_net_iface_id_seq;
