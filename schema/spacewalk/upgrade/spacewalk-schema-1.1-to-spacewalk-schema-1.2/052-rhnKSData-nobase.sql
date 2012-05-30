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

alter trigger rhn_ks_mod_trig disable;

alter table rhnKsData add (
    no_base         CHAR(1)
                        DEFAULT ('N') NOT NULL
                        CONSTRAINT rhn_ks_nobase_ck
                            CHECK (no_base in ( 'Y' , 'N' )),
    ignore_missing  CHAR(1)
                        DEFAULT ('N') NOT NULL
                        CONSTRAINT rhn_ks_ignore_missing_ck
                            CHECK (ignore_missing in ( 'Y' , 'N' ))
);

alter trigger rhn_ks_mod_trig enable;
