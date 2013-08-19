--
-- Copyright (c) 2013 SUSE
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
--

-- Create new column for rhnUserInfo
ALTER TABLE rhnUserInfo ADD csv_separator CHAR(1) DEFAULT (',') NOT NULL
    CONSTRAINT rhn_user_info_csv_ck
        CHECK (csv_separator in (',',';'));
