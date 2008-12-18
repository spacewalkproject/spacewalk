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
-- list of available timezones and the string to use to display them

create sequence rhn_timezone_id_seq start with 7000 order;

create table 
rhnTimezone
(
        id              number
			constraint rhn_timezone_id_nn not null,
        olson_name      varchar2(128)
	    	    	constraint rhn_timezone_olson_nn not null,
	display_name    varchar2(128)
	    	    	constraint rhn_timezone_display_nn not null
)
	enable row movement
  ;

create index rhn_timezone_id_idx
	on rhnTimezone( id )
	tablespace [[64k_tbs]]
  ;
alter table rhnTimezone add constraint rhn_timezone_id_pk
	primary key ( id );

create unique index rhn_timezone_olson_uq
	on rhnTimezone(olson_name);

create unique index rhn_timezone_display_uq
	on rhnTimezone(display_name);
