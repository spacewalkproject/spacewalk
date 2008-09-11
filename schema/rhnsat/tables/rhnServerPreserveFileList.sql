--
-- $Id$
--

create table
rhnServerPreserveFileList
(
	server_id	number
			constraint rhn_serverpfl_ksid_nn not null
			constraint rhn_serverpfl_ksid_fk
				references rhnServer(id),
	file_list_id	number
			constraint rhn_serverpfl_flid_nn not null
			constraint rhn_serverpfl_flid_fk
				references rhnFileList(id)
				on delete cascade,
	created		date default (sysdate)
			constraint rhn_serverpfl_creat_nn not null,
	modified	date default (sysdate)
			constraint rhn_serverpfl_mod_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_serverpfl_ksid_flid_uq
	on rhnServerPreserveFileList( server_id, file_list_id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- needed for delete server
create index rhn_serverpfl_flid_ksid_idx
	on rhnServerPreserveFileList( file_list_id, server_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_serverpfl_mod_trig
before insert or update on rhnServerPreserveFileList
for each row
begin
	:new.modified := sysdate;
end rhn_serverpfl_mod_trig;
/
show errors

--
-- $Log$
-- Revision 1.2  2004/05/28 19:30:24  pjones
-- bugzilla: 123426 -- when the file list is deleted, remove the reference to it.
--
-- Revision 1.1  2004/05/25 02:25:34  pjones
-- bugzilla: 123426 -- tables in which to keep lists of files to be preserved.
--
