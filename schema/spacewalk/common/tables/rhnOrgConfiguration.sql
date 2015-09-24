--
-- Copyright (c) 2013--2015 Red Hat, Inc.
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

create table rhnOrgConfiguration
(
    org_id                     number not null
                                   constraint rhn_org_conf_org_id_fk
                                   references web_customer(id)
                                   on delete cascade,
    staging_content_enabled    char(1)
                                   default ('N') not null
                                   constraint rhn_org_conf_stage_content_chk
                                   check (staging_content_enabled in ('Y', 'N')),
    errata_emails_enabled      char(1)
                                    default ('Y') not null
                                    constraint rhn_org_conf_errata_emails_chk
                                    check (errata_emails_enabled in ('Y', 'N')),
    crash_reporting_enabled    char(1)
                                   default ('Y') not null
                                   constraint rhn_org_conf_crash_report_chk
                                   check (crash_reporting_enabled in ('Y', 'N')),
    crashfile_upload_enabled   char(1)
                                   default ('Y') not null
                                   constraint rhn_org_conf_crash_upload_chk
                                   check (crashfile_upload_enabled in ('Y', 'N')),
    crash_file_sizelimit       number
                                   default(2048) not null
                                   constraint rhn_org_conf_sizelimit_chk
                                   check (crash_file_sizelimit >= 0),
    scapfile_upload_enabled    char(1)
                                   default ('N') not null
                                   constraint rhn_org_conf_scap_upload_chk
                                   check (scapfile_upload_enabled in ('Y', 'N')),
    scap_file_sizelimit        number
                                   default(2097152) not null
                                   constraint rhn_org_conf_scap_szlmt_chk
                                   check (scap_file_sizelimit >= 0),
    scap_retention_period_days number
                                   default(90)
                                   constraint rhn_org_conf_scap_reten_chk
                                   check (scap_retention_period_days >= 0),
    create_default_sg          char(1)
                                    default('N') not null
                                    constraint rhn_org_cong_deforg_chk
                                    check (create_default_sg in ('Y', 'N')),
    created                    timestamp with local time zone
                                   default (current_timestamp) not null,
    modified                   timestamp with local time zone
                                   default (current_timestamp) not null
)
enable row movement
;

create unique index rhn_org_conf_org_id
    on rhnOrgConfiguration (org_id)
    tablespace [[8m_tbs]];
