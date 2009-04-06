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


CREATE TABLE web_user_personal_info
(
    web_user_id        NUMBER NOT NULL 
                           CONSTRAINT personal_info_web_user_id_fk
                               REFERENCES web_contact (id) 
                               ON DELETE CASCADE, 
    prefix             VARCHAR2(12) 
                           DEFAULT (' ') NOT NULL 
                           CONSTRAINT wupi_prefix_fk
                               REFERENCES web_user_prefix (text), 
    first_names        VARCHAR2(128) NOT NULL, 
    last_name          VARCHAR2(128) NOT NULL, 
    genqual            VARCHAR2(12), 
    parent_company     VARCHAR2(128), 
    company            VARCHAR2(128), 
    title              VARCHAR2(128), 
    phone              VARCHAR2(128), 
    fax                VARCHAR2(128), 
    email              VARCHAR2(128), 
    email_uc           VARCHAR2(128), 
    pin                NUMBER, 
    created            DATE 
                           DEFAULT (sysdate) NOT NULL, 
    modified           DATE 
                           DEFAULT (sysdate) NOT NULL, 
    first_names_ol     VARCHAR2(128), 
    last_name_ol       VARCHAR2(128), 
    genqual_ol         VARCHAR2(12), 
    parent_company_ol  VARCHAR2(128), 
    company_ol         VARCHAR2(128), 
    title_ol           VARCHAR2(128)
)
ENABLE ROW MOVEMENT
;

CREATE INDEX wupi_email_uc_idx
    ON web_user_personal_info (email_uc);

