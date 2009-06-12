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


CREATE TABLE rhnKickstartCommandName
(
    id              NUMBER NOT NULL
                        CONSTRAINT rhn_kscommandname_id_pk PRIMARY KEY
                        USING INDEX TABLESPACE [[2m_tbs]],
    name            VARCHAR2(128) NOT NULL,
    uses_arguments  CHAR(1) NOT NULL
                        CONSTRAINT rhn_kscommandname_uses_args_ck
                            CHECK (uses_arguments in ( 'Y' , 'N' )),
    sort_order      NUMBER NOT NULL,
    required        CHAR(1)
                        DEFAULT ('N') NOT NULL
                        CONSTRAINT rhn_kscommandname_reqrd_ck
                            CHECK (required in ( 'Y' , 'N' ))
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_kscommandname_name_id_idx
    ON rhnKickstartCommandName (name, id)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_kscommandname_id_seq;

ALTER TABLE rhnKickstartCommandName
    ADD CONSTRAINT rhn_kscommandname_name_uq UNIQUE (name);

