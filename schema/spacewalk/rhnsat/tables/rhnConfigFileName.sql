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
-- $Id$
--

create sequence rhn_cfname_id_seq;

create table
rhnConfigFileName
(
	id		number
			constraint rhn_cfname_id_nn not null,
	path		varchar2(1024)
			constraint rhn_cfname_path_nn not null,
	created		date default(sysdate)
			constraint rhn_cfname_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_cfname_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_cfname_id_pk
	on rhnConfigFileName ( id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnConfigFileName add constraint
	rhn_cfname_id_pk primary key ( id );

create unique index rhn_cfname_path_uq
	on rhnConfigFileName ( path )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_cfname_mod_trig
before insert or update on rhnConfigFileName
for each row
begin
	:new.modified := sysdate;
end;
/
	
-- $Log$
-- Revision 1.1  2003/07/30 23:37:21  pjones
-- bugzilla: none
-- config file schema
--
