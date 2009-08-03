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


CREATE TABLE rhnBeehivePathMap
(
    path          VARCHAR2(128) NOT NULL
                      CONSTRAINT rhn_beehive_path_map_p_pk PRIMARY KEY
                      USING INDEX TABLESPACE [[64k_tbs]],
    beehive_path  VARCHAR2(128) NOT NULL,
    ftp_path      VARCHAR2(128) NOT NULL,
    created       DATE
                      DEFAULT (SYSDATE),
    modified      DATE
                      DEFAULT (SYSDATE)
)
ENABLE ROW MOVEMENT
;

