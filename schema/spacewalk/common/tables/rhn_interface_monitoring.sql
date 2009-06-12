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


CREATE TABLE rhn_interface_monitoring
(
    server_id    NUMBER NOT NULL
                     CONSTRAINT rhn_monif_server_pk PRIMARY KEY
                     USING INDEX TABLESPACE [[8m_tbs]],
    server_name  VARCHAR2(32) NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_interface_monitoring IS 'monif  Monitoring interface.  The one entry from rhnservernetinterface to be used for monitoring on a host.';

CREATE UNIQUE INDEX rhn_int_mont_sid_sname_idx
    ON rhn_interface_monitoring (server_id, server_name)
    TABLESPACE [[8m_tbs]]
    NOLOGGING;

ALTER TABLE rhn_interface_monitoring
    ADD CONSTRAINT rhn_monif_server_name_fk FOREIGN KEY (server_id, server_name)
    REFERENCES rhnServerNetInterface (server_id, name);

