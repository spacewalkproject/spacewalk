--
-- Copyright (c) 2010 Red Hat, Inc.
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


CREATE TABLE rhnTaskoBunch
(
    id          NUMBER NOT NULL
                    CONSTRAINT rhn_tasko_bunch_id_pk PRIMARY KEY,
    name        VARCHAR2(80) NOT NULL
                    CONSTRAINT tasko_bunch_name_uq UNIQUE,
    description VARCHAR2(200),
    active_from DATE NOT NULL,
    active_till DATE,
    created     DATE
                    DEFAULT (sysdate) NOT NULL,
    modified    DATE
                    DEFAULT (sysdate) NOT NULL
)
;

CREATE SEQUENCE rhn_tasko_bunch_id_seq;
