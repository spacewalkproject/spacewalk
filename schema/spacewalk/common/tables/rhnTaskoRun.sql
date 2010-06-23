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


CREATE TABLE rhnTaskoRun
(
    id              NUMBER NOT NULL
                        CONSTRAINT rhn_tasko_run_id_pk PRIMARY KEY,
    template_id     NUMBER NOT NULL
                        CONSTRAINT rhn_tasko_run_template_fk
                        REFERENCES rhnTaskoTemplate (id),
    schedule_id     NUMBER NOT NULL
                        CONSTRAINT rhn_tasko_run_schedule_fk
                        REFERENCES rhnTaskoSchedule (id),
    org_id          NUMBER,
    start_time      DATE,
    end_time        DATE,
    std_output_path VARCHAR2(100),
    std_error_path  VARCHAR2(100),
    status          CHAR(10),
    created         DATE
                        DEFAULT (sysdate) NOT NULL,
    modified        DATE
                        DEFAULT (sysdate) NOT NULL
)
;

CREATE SEQUENCE rhn_tasko_run_id_seq;
