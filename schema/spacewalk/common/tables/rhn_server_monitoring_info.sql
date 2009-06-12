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


CREATE TABLE rhn_server_monitoring_info
(
    recid  NUMBER NOT NULL
               CONSTRAINT rhn_host_recid_pk PRIMARY KEY
               USING INDEX TABLESPACE [[4m_tbs]],
    os_id  NUMBER
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_server_monitoring_info IS 'host   additional fields to rhn_server for monitoring servers';

ALTER TABLE rhn_server_monitoring_info
    ADD CONSTRAINT rhn_host_server_id_fk FOREIGN KEY (recid)
    REFERENCES rhnServer (id);

ALTER TABLE rhn_server_monitoring_info
    ADD CONSTRAINT rhn_host_server_name_fk FOREIGN KEY (os_id)
    REFERENCES rhn_os (recid);

