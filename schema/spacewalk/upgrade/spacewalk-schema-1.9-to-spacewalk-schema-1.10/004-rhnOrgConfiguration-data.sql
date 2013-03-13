--
-- Copyright (c) 2013 Red Hat, Inc.
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

insert into rhnOrgConfiguration (
    org_id,
    staging_content_enabled,
    crash_reporting_enabled,
    crashfile_upload_enabled,
    crash_file_sizelimit )
(
    select id,
           staging_content_enabled,
           'Y',
           'Y',
           crash_file_sizelimit
      from web_customer
);
