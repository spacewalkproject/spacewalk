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


CREATE TABLE rhn_schedule_types
(
    recid        NUMBER NOT NULL
                     CONSTRAINT rhn_schtp_recid_pk PRIMARY KEY
                     USING INDEX TABLESPACE [[64k_tbs]]
                     CONSTRAINT rhn_schtp_recid_ck
                         CHECK (recid > 0),
    description  VARCHAR2(40)
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_schedule_types IS 'schtp  schedule types';

CREATE SEQUENCE rhn_schedule_types_recid_seq;

