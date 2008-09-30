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
	id		number
			constraint rhn_cpuarch_id_nn not null,
	label		varchar2(64)
			constraint rhn_cpuarch_label_nn not null,
	name		varchar2(64)
			constraint rhn_cpuarch_name_nn not null,
	created		date default(sysdate)
			constraint rhn_cpuarch_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_cpuarch_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_cpu_arch_id_seq start with 200;

-- these must be in this order.
create index rhn_cpuarch_id_l_n_idx
	on rhnCpuArch(id,label,name)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnCpuArch add constraint rhn_cpuarch_id_pk primary key (id);

-- these too.
create index rhn_cpuarch_l_id_n_idx
	on rhnCpuArch(label,id,name)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnCpuArch add constraint rhn_cpuarch_label_uq unique ( label );

create or replace trigger
rhn_cpuarch_mod_trig
before insert or update on rhnCpuArch
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.3  2004/02/05 18:45:58  pjones
-- bugzilla: 115009 -- make the labels really big
--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/11/14 16:30:36  misa
-- Arches for CPUs
--
