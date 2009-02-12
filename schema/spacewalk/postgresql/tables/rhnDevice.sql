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

create table
rhnDevice
(
	id		numeric
			not null
			constraint rhn_device_id_pk primary key
--			using index tablespace [[32m_tbs]]
                        ,
	server_id	numeric
			not null
			constraint rhn_device_sid_fk
			references rhnServer(id) on delete cascade,
	class		varchar(16),
	bus		varchar(16),
	detached	numeric,
	device		varchar(16),
	driver		varchar(256),
	description	varchar(256),
	pcitype		numeric default -1,
	prop1		varchar(256),
	prop2		varchar(256),
	prop3		varchar(256),
	prop4		varchar(256),
	created		date default (current_date)
			not null,
	modified	date default (current_date)
			not null
)
  ;

create sequence rhn_hw_dev_id_seq;

create index rhn_device_server_id_idx
	on rhnDevice(server_id)
--	tablespace [[32m_tbs]]
	;
/*
create or replace trigger
rhn_device_mod_trig
before insert or update on rhnDevice
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.9  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.8  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.7  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[32m_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.6  2001/07/24 22:17:00  cturner
-- nologging on a bunch of indexes... fun
--
-- Revision 1.5  2001/07/05 20:42:34  pjones
-- rename constraint
-- format
--
-- Revision 1.4  2001/07/01 06:16:56  gafton
-- named constraints, dammit.
--
-- Revision 1.3  2001/06/27 05:04:35  pjones
-- this makes tables work
--
-- Revision 1.2  2001/06/27 02:18:12  pjones
-- triggers
--
-- Revision 1.1  2001/06/27 01:46:05  pjones
-- initial checkin
