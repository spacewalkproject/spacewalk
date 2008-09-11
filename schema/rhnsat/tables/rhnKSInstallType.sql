--
-- $Id$
--

create sequence rhn_ksinstalltype_id_seq;

create table
rhnKSInstallType
(
        id              number
			constraint rhn_ksinstalltype_id_nn not null
                        constraint rhn_ksinstalltype_id_pk primary key
                                using index tablespace [[64k_tbs]],
        label           varchar2(32)
                        constraint rhn_ksinstalltype_label_nn not null,
        name            varchar2(64)
                        constraint rhn_ksinstalltype_name_nn not null,
        created         date default(sysdate)
                        constraint rhn_ksinstalltype_created_nn not null,
        modified        date default(sysdate)
                        constraint rhn_ksinstalltype_mod_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_ksinstalltype_label_uq 
	on rhnKSInstallType( label )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_ksinstalltype_mod_trig
before insert or update on rhnKSInstallType
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.2  2003/12/12 21:19:35  pjones
-- bugzilla: none -- fix somebody's very very sloppy table creation.
--
