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


CREATE TABLE rhnRepoRegenQueue
(
    id              NUMBER 
                        CONSTRAINT rhn_reporegenq_id_pk PRIMARY KEY, 
    channel_label   VARCHAR2(128) NOT NULL, 
    client          VARCHAR2(128), 
    reason          VARCHAR2(128), 
    force           CHAR(1), 
    bypass_filters  CHAR(1), 
    next_action     DATE 
                        DEFAULT (sysdate), 
    created         DATE 
                        DEFAULT (sysdate) NOT NULL, 
    modified        DATE 
                        DEFAULT (sysdate) NOT NULL
)
;

CREATE SEQUENCE rhn_repo_regen_queue_id_seq START WITH 101;

