--
-- Copyright (c) 2014 Red Hat, Inc.
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

CREATE TABLE rhnConfiguration
(
    key                     VARCHAR2(64) NOT NULL
                                CONSTRAINT rhnConfig_key_pk PRIMARY KEY,
    description             VARCHAR2(512) NOT NULL,
    value                   VARCHAR2(512),
    default_value           VARCHAR2(512),
    created                 TIMESTAMP WITH LOCAL TIME ZONE
                                DEFAULT (current_timestamp) NOT NULL,
    modified                TIMESTAMP WITH LOCAL TIME ZONE
                                DEFAULT (current_timestamp) NOT NULL
)
ENABLE ROW MOVEMENT
;
