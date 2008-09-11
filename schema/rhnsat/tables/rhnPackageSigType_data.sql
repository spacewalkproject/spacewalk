--
-- $Id$
--
-- data for rhnPackageSigType

insert into rhnPackageSigType values (
        rhn_package_sig_type_id_seq.nextval,
        'MD5',sysdate,sysdate
);
insert into rhnPackageSigType values (
        rhn_package_sig_type_id_seq.nextval,
        'SHA1',sysdate,sysdate
);
insert into rhnPackageSigType values (
        rhn_package_sig_type_id_seq.nextval,
        'PGP',sysdate,sysdate
);
insert into rhnPackageSigType values (
        rhn_package_sig_type_id_seq.nextval,
        'GPG',sysdate,sysdate
);

commit;

-- $Log$
-- Revision 1.1  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
