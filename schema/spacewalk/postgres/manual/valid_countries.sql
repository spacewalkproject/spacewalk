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
--
--
--
-- This is "web.valid_countries".  It's flagged for not production currently;
-- this is what we've used in satellite.
--
-- EXCLUDE: production

create table valid_countries (
    code       varchar(2)    NOT NULL
                             CONSTRAINT valid_countries_pk
                             PRIMARY KEY,
    short_name varchar(80) NOT NULL,
    name       varchar(240)
);

create table valid_countries_tl (
    lang          char(2)     NOT NULL,
    code          varchar(2)  NOT NULL
			      CONSTRAINT valid_countries_tl_code
                                REFERENCES valid_countries(code),
    short_name_tl varchar(80) NOT NULL,
                              CONSTRAINT valid_countries_tl_unq
                                UNIQUE (lang, code)
);

