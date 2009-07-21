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


CREATE TABLE rhn_strategies
(
    recid             NUMBER(12) NOT NULL
                          CONSTRAINT rhn_strat_recid_pk PRIMARY KEY
                          USING INDEX TABLESPACE [[64k_tbs]]
                          CONSTRAINT rhn_strat_recid_ck
                              CHECK (recid > 0),
    name              VARCHAR2(80),
    comp_crit         VARCHAR2(80),
    esc_crit          VARCHAR2(80),
    contact_strategy  VARCHAR2(32)
                          CONSTRAINT rhn_strat_cont_strat_ck
                              CHECK (contact_strategy in ( 'Broadcast' , 'Escalate' )),
    ack_completed     VARCHAR2(32)
                          CONSTRAINT rhn_strat_ack_comp_ck
                              CHECK (ack_completed in ( 'All' , 'One' , 'No' ))
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_strategies IS 'strat  strategy definitions';

CREATE SEQUENCE rhn_strategies_recid_seq;

