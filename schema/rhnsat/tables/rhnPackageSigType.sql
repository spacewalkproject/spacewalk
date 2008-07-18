--
-- $Id$
--

-- we have enough that it seems useful to have a lookup table. 
-- that is to say, we have more than one.
-- 1-4 are: MD5, SHA1, PGP, and GPG.  Its probably worth it to keep the
-- inserts up to date here in the schema.
create table
rhnPackageSigType
(
        id              number
			constraint rhn_pkg_sigtype_id_nn  not null
                        constraint rhn_pkg_sigtype_id_pk primary key
				using index tablespace [[64k_tbs]],
        name            varchar2(32)
			constraint rhn_pkg_sigtype_name_nn not null,
        created         date default (sysdate)
			constraint rhn_pkg_sigtype_created_nn not null,
        modified        date default (sysdate)
			constraint rhn_pkg_sigtype_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_package_sig_type_id_seq;

create unique index rhn_pkg_sigtype_name_uq
	on rhnPackageSigType(name)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_package_sig_type_mod_trig
before insert or update on rhnPackageSigType
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.12  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.11  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
