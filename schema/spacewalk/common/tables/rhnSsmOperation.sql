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


CREATE TABLE rhnSsmOperation
(
    id           NUMBER NOT NULL 
                     CONSTRAINT rhn_ssmop_id_pk PRIMARY KEY 
                     USING INDEX TABLESPACE [[4m_tbs]], 
    user_id      NUMBER NOT NULL 
                     CONSTRAINT rhn_ssmop_user_fk
                         REFERENCES web_contact (id) 
                         ON DELETE CASCADE, 
    description  VARCHAR2(256) NOT NULL, 
    status       VARCHAR2(32) NOT NULL, 
    started      DATE NOT NULL, 
    modified     DATE 
                     DEFAULT (sysdate) NOT NULL
)
;

CREATE SEQUENCE rhn_ss_op_seq;

