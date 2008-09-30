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

--
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
