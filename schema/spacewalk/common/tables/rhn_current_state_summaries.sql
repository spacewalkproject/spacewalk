--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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


CREATE TABLE rhn_current_state_summaries
(
    customer_id  NUMBER(12) NOT NULL,
    template_id  VARCHAR2(10) NOT NULL,
    state        VARCHAR2(20) NOT NULL,
    state_count  NUMBER(9),
    last_check   DATE
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_current_state_summaries IS 'cursu  current state summaries (monitoring)';

CREATE UNIQUE INDEX rhn_current_state_summaries_pk
    ON rhn_current_state_summaries (customer_id, template_id, state)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhn_current_state_summaries
    ADD CONSTRAINT rhn_current_state_summaries_pk PRIMARY KEY (customer_id, template_id, state);

