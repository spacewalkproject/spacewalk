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

create sequence rhn_actionks_id_seq;

create table
rhnActionKickstart
(
	id			number
				constraint rhn_actionks_id_nn not null,
	action_id		number
				constraint rhn_actionks_aid_nn not null
				constraint rhn_actionks_aid_fk
					references rhnAction(id)
					on delete cascade,
	append_string		varchar2(1024),
	kickstart_host		varchar2(256),
        static_device           varchar2(32),
        cobbler_system_name             varchar2(256),
	created			date default(sysdate)
				constraint rhn_actionks_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_actionks_mod_nn not null
)
	enable row movement
  ;

create unique index rhn_actionks_aid_uq
	on rhnActionKickstart( action_id )
	tablespace [[8m_tbs]]
  ;

create index rhn_actionks_id_idx
	on rhnActionKickstart( id )
	tablespace [[4m_tbs]]
  ;
alter table rhnActionKickstart add constraint rhn_actionks_id_pk
	primary key ( id );

create or replace trigger
rhn_actionks_mod_trig
before insert or update on rhnActionKickstart
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
--
-- Revision 1.9  2008/12/05 06:53:22  paji
-- bugzilla: none -- removing the kstree_id as it provides
-- no useful information. This change will enable us to 
-- use cobbler only profiles..
---
-- Revision 1.8  2004/05/27 22:59:34  pjones
-- bugzilla: none -- rhnActionKickstartFileList, so we can find what KSData
-- the filelist comes from on an action.  I need a bug for this...
--
-- Revision 1.7  2004/03/15 16:41:57  pjones
-- bugzilla: 118245 -- on delete cascades for deleting actions
--
-- Revision 1.6  2004/01/14 21:43:33  pjones
-- bugzilla: 113416 -- fix cascade on delete of rhnKickstartableTree
--
-- Revision 1.5  2003/11/17 20:25:10  cturner
-- add the static_device to rhnActionKickstart in addition to rhnKSData
--
-- Revision 1.4  2003/11/15 20:49:16  cturner
-- bugzilla: 107799, remove the column I needlessly created
--
-- Revision 1.3  2003/11/12 04:19:22  cturner
-- bugzilla: 107799, add kernel_params schema for kickstarting
--
-- Revision 1.2  2003/10/15 16:18:08  pjones
-- bugzilla: 106718 -- fix uniqueness constraint to only be on action_id
--
-- Revision 1.1  2003/10/09 22:17:50  pjones
-- bugzilla: 106718
-- add rhnActionKickstart
--

