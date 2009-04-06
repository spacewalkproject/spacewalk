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
rhnCpu
(
	id		numeric
			constraint rhn_cpu_id_pk primary key
--			using index tablespace [[4m_tbs]]
                        ,
	server_id	numeric
			not null
			constraint rhn_cpu_server_fk
			references rhnServer(id),
	cpu_arch_id	numeric
			constraint rhn_cpu_caid_nn not null
			constraint rhn_cpu_caid_fk
			references rhnCpuArch(id),
	bogomips	varchar(16),
	cache		varchar(16),
	family		varchar(32),
	MHz		varchar(16),
	stepping	varchar(16),
	flags		varchar(2048),
	model		varchar(64),
	version		varchar(32),
	vendor		varchar(32),
	nrcpu		numeric default 1,
	acpiVersion	varchar(64),
	apic		varchar(32),
	apmVersion	varchar(32),
	chipset		varchar(64),
	created		date default (current_date)
			not null,
	modified	date default (current_date)
			not null
)
  ;

create sequence rhn_cpu_id_seq;

create index rhn_cpu_server_id_idx on
	rhnCpu(server_id)
--	tablespace [[4m_tbs]]
	;
/*
create or replace trigger
rhn_cpu_mod_trig
before insert or update on rhnCpu
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.17  2004/03/22 18:25:06  misa
-- Extend rhnCpu.flags
--
-- Revision 1.16  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.15  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.14  2002/11/14 17:31:37  pjones
-- more arch changes -- remove the old fields
--
-- Revision 1.13  2002/11/14 17:14:20  misa
-- we have a cpu arch table now - show it in the name too
--
-- Revision 1.12  2002/11/14 17:11:52  misa
-- we have a cpu arch table now
--
-- Revision 1.11  2002/11/13 22:45:20  pjones
-- add appropriate arch fields.
-- haven't deleted the old ones yet though
--
-- Revision 1.10  2002/03/19 22:41:30  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.9  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[4m_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.8  2001/07/24 22:17:00  cturner
-- nologging on a bunch of indexes... fun
--
-- Revision 1.7  2001/07/01 06:47:10  gafton
-- fix up the stupid syntax errors
--
-- Revision 1.6  2001/07/01 06:39:01  gafton
-- stupid comma!
--
-- Revision 1.5  2001/07/01 06:29:04  gafton
-- syntax error fix
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
