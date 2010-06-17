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


CREATE TABLE rhnTaskoSchedule
(
    id              NUMBER NOT NULL
                        CONSTRAINT rhn_tasko_schedule_id_pk PRIMARY KEY,
    job_label       VARCHAR2(50) NOT NULL,
    bunch_id        NUMBER NOT NULL
                        CONSTRAINT rhn_tasko_schedule_bunch_fk
                        REFERENCES rhnTaskoBunch (id),
    org_id          NUMBER,
    active          VARCHAR2(1),
    active_from     DATE,
    active_till     DATE,
    cron_expr       VARCHAR2(20),
    data            BLOB,
    created         DATE
                        DEFAULT (sysdate) NOT NULL,
    modified        DATE
                        DEFAULT (sysdate) NOT NULL
)
;

CREATE SEQUENCE rhn_tasko_schedule_id_seq;
