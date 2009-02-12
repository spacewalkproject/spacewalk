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
-- EXCLUDE: production
--
-- this holds our satellite cert.

create table
rhnSatelliteCert
(
	label			varchar(64)
				not null,
	version			numeric,
	cert			bytea
				not null,
	-- issued and expires are derived from the "cert" data, but we
	-- need them to search for certs that have expired.
	issued			date default(current_date),
	expires			date default(current_date),
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null
)
  ;

/*
create or replace trigger
rhn_satcert_mod_trig
before insert or update on rhnSatelliteCert 
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

create unique index rhn_satcert_label_version_uq on
	rhnSatelliteCert ( label, version )
	tablespace [[64k_tbs]]
  ;
*/
--
-- Revision 1.7  2004/05/25 20:58:31  pjones
-- bugzilla: none -- make issued/expires nullable
--
-- Revision 1.6  2004/05/19 16:47:16  pjones
-- bugzilla: 90769 -- add issued and expires dates to the data about the cert
--
-- Revision 1.5  2004/04/22 15:19:28  misa
-- cert is now a blob
--
-- Revision 1.4  2003/05/15 20:56:25  pjones
-- bugzilla: 90869
--
-- make rhnSatelliteCert have a version
--
-- Revision 1.3  2003/04/14 19:33:31  cturner
-- typo fix
--
-- Revision 1.2  2003/04/11 15:06:59  pjones
-- add label, fix the storage options
--
-- Revision 1.1  2003/04/10 15:01:09  pjones
-- bugzilla: none
--
-- table to hold a cert on the satellite
--
