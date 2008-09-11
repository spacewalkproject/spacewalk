--
-- $Id$
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
	kstree_id		number
				constraint rhn_actionks_kstid_nn not null
				constraint rhn_actionks_kstid_fk
					references rhnKickstartableTree(id)
					on delete cascade,
        static_device           varchar2(32),
	created			date default(sysdate)
				constraint rhn_actionks_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_actionks_mod_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_actionks_aid_uq
	on rhnActionKickstart( action_id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_actionks_id_idx
	on rhnActionKickstart( id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;
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
-- $Log$
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

