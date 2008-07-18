--
-- $Id$
--

create sequence rhn_ssinvalid_id_seq;

create table
rhnSnapshotInvalidReason
(
	id			number
				constraint rhn_ssinvalid_id_nn not null
				constraint rhn_ssinvalid_id_pk primary key
					using index tablespace [[64k_tbs]],
	label			varchar2(32)
				constraint rhn_ssinvalid_label_nn not null,
	name			varchar2(128)
				constraint rhn_ssinvalid_name_nn not null,
	created			date default(sysdate)
				constraint rhn_ssinvalid_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_ssinvalid_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_ssinvalid_label_uq
	on rhnSnapshotInvalidReason(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_ssinvalid_mod_trig
before insert or update on rhnSnapshotInvalidReason
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.1  2003/10/07 20:49:18  pjones
-- bugzilla: 106188
--
-- snapshot invalidation
--
