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


CREATE TABLE rhnUserInfo
(
    user_id                 NUMBER NOT NULL 
                                CONSTRAINT rhn_user_info_user_fk
                                    REFERENCES web_contact (id) 
                                    ON DELETE CASCADE, 
    no_clear_sets           NUMBER 
                                DEFAULT (0) NOT NULL, 
    page_size               NUMBER 
                                DEFAULT (20) NOT NULL, 
    email_notify            NUMBER 
                                DEFAULT (1) NOT NULL, 
    bad_email               NUMBER 
                                DEFAULT (0) NOT NULL, 
    tz_offset               NUMBER 
                                DEFAULT (-5) NOT NULL 
                                CONSTRAINT rhn_user_info_tzoffset_ck
                                    CHECK (tz_offset >= -11 and tz_offset <= 13), 
    timezone_id             NUMBER 
                                CONSTRAINT rhn_user_info_tzid_fk
                                    REFERENCES rhnTimezone (id) 
                                    ON DELETE CASCADE, 
    show_applied_errata     CHAR(1) 
                                DEFAULT ('N') NOT NULL 
                                CONSTRAINT rhn_user_info_sea_ck
                                    CHECK (show_applied_errata in ( 'Y' , 'N' )), 
    show_system_group_list  CHAR(1) 
                                DEFAULT ('N') NOT NULL 
                                CONSTRAINT rhn_user_info_ssgl_ck
                                    CHECK (show_system_group_list in ( 'Y' , 'N' )), 
    agreed_to_terms         CHAR(1) 
                                DEFAULT ('N') NOT NULL 
                                CONSTRAINT rhn_user_info_agreed_ck
                                    CHECK (agreed_to_terms in ( 'Y' , 'N' )), 
    use_pam_authentication  CHAR(1) 
                                DEFAULT ('N') NOT NULL 
                                CONSTRAINT rhn_user_info_pam_ck
                                    CHECK (use_pam_authentication in ( 'Y' , 'N' )), 
    last_logged_in          DATE, 
    agreed_to_ws_terms      CHAR(1) 
                                CONSTRAINT rhn_user_info_ws_ck
                                    CHECK (agreed_to_ws_terms is null or agreed_to_ws_terms in ( 'Y' , 'N' )), 
    agreed_to_es_terms      CHAR(1) 
                                CONSTRAINT rhn_user_info_es_ck
                                    CHECK (agreed_to_es_terms is null or agreed_to_es_terms in ( 'Y' , 'N' )), 
    created                 DATE 
                                DEFAULT (sysdate) NOT NULL, 
    modified                DATE 
                                DEFAULT (sysdate) NOT NULL, 
    preferred_locale        VARCHAR2(8)
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_user_info_uid_email_idx
    ON rhnUserInfo (user_id, email_notify)
    TABLESPACE [[4m_tbs]];

ALTER TABLE rhnUserInfo
    ADD CONSTRAINT rhn_user_info_uid_uq UNIQUE (user_id);

