-- oracle equivalent source sha1 93bf333fd11c59fc18c593d8adcab35f31df5a91
--
-- Copyright (c) 2010--2012 Red Hat, Inc.
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

create temporary table store_searchpath as select setting from pg_settings where name = 'search_path';

-- The spaces in front of \i are needed to stop blend from expanding
-- in build time.
   \i /usr/share/pgsql/contrib/dblink.sql

update pg_settings set setting = (select setting from store_searchpath) where name = 'search_path';
drop table store_searchpath;
