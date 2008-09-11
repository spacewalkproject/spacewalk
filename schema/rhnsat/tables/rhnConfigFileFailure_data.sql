-- $Id$

insert into rhnConfigFileFailure (id, label, name) values
    (rhn_conffile_failure_id_seq.nextval, 'missing',
    'Missing file');

insert into rhnConfigFileFailure (id, label, name) values
    (rhn_conffile_failure_id_seq.nextval, 'too_big',
    'File too big');

insert into rhnConfigFileFailure (id, label, name) values
    (rhn_conffile_failure_id_seq.nextval, 'binary_file',
    'Binary file');

insert into rhnConfigFileFailure (id, label, name) values
    (rhn_conffile_failure_id_seq.nextval, 'insufficient_quota',
    'Insufficient free quota space');


commit;

-- $Log$
-- Revision 1.3  2004/01/07 18:05:37  bretm
-- bugzilla:  112901
--
-- new type of failure reason:  insufficient quota space
--
-- Revision 1.2  2003/11/17 14:37:44  misa
-- One more reason for a diff to fail: binary files
--
-- Revision 1.1  2003/11/15 01:45:33  misa
-- bugzilla: 107284  Schema for storing missing files
--
--
