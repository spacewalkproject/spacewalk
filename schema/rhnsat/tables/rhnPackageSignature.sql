--
-- $Id$
--/

-- signature is a varchar not a blob so it can be in the UNIQUE().  Also, it
-- is not larger for that reason (maximum unique() is 3218 bytes, and numbers
-- seem to get something larger than four.  3100 seemed to work, but I evened
-- it out at 3000 because I like zeros.  That should be larger than any of our
-- signatures, right?  Also, varchar2() gives you no more space than you 
-- actually use.
create table
rhnPackageSignature
(
        id              number
			constraint rhn_pkg_sig_id_nn not null
                        constraint rhn_pkg_sig_id_pk primary key
                        using index tablespace [[64k_tbs]],
        package_id      number
			constraint rhn_pkg_sig_pid_nn not null
                        constraint rhn_pkg_sig_pid_fk
                                references rhnPackage(id),
        type_id         number
			constraint rhn_pkg_sig_tid_nn not null
                        constraint rhn_pkg_sig_tid_fk
                                references rhnPackageSigType(id),
        signature       varchar2(3000)
			constraint rhn_pkg_sig_signature_nn not null,
        created         date default (sysdate)
			constraint rhn_pkg_sig_created_nn not null,
        modified        date default (sysdate)
			constraint rhn_pkg_sig_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_package_sig_id_seq;

create unique index rhn_pkg_sig_pid_tid_sig_uq
	on rhnPackageSignature(package_id, type_id, signature)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_pkg_sig_pid_idx
	on rhnPackageSignature(package_Id)
        nologging tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_package_sig_mod_trig
before insert or update on rhnPackageSignature
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.14  2004/12/07 20:18:56  cturner
-- bugzilla: 142156, simplify the triggers
--
-- Revision 1.13  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.12  2003/01/24 16:42:23  pjones
-- last_modified on rhnPackage and rhnPackageSource
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
