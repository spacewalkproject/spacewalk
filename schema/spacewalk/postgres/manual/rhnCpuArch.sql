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
rhnCpuArch
(
	id		numeric
			constraint rhn_cpuarch_id_pk primary key,
	label		varchar(64)
			not null
                        constraint rhn_cpuarch_label_uq unique,
	name		varchar(64)
			not null,
	created		date default(current_date)
			not null,
	modified	date default(current_date)
			not null
)
  ;

create sequence rhn_cpu_arch_id_seq start with 200;

-- these must be in this order.
create index rhn_cpuarch_id_l_n_idx
	on rhnCpuArch(id,label,name)
--	tablespace [[2m_tbs]]
  ;

-- these too.
create index rhn_cpuarch_l_id_n_idx
	on rhnCpuArch(label,id,name)
--	tablespace [[2m_tbs]]
  ;

/*
create or replace trigger
rhn_cpuarch_mod_trig
before insert or update on rhnCpuArch
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.3  2004/02/05 18:45:58  pjones
-- bugzilla: 115009 -- make the labels really big
--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/11/14 16:30:36  misa
-- Arches for CPUs
--
