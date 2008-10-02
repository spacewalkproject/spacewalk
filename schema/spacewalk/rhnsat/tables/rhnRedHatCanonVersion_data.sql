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
-- data for rhnRedHatCanonVersion

insert into rhnRedHatCanonVersion (version, canon_version) values (
    'Red Hat Linux 7.1'         , '7.1');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    'Red_Hat_Linux_7.1'         , '7.1');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.1sbe'                    , '7.1');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    'Red Hat Linux 7.0.91'      , '7.1');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    'Red Hat Linux 7.0.95'      , '7.1');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.0.90'                    , '7.1');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.0.91'                    , '7.1');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.0.93'                    , '7.1');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.0.95'                    , '7.1');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    'Red Hat Linux 7'           , '7.0');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    'Red Hat Linux 7.0j'        , '7.0');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.0J'                      , '7.0');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.0.1J'                    , '7.0');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    'Red Hat Linux 6.2'         , '6.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    'Red_Hat_Linux_6.2'         , '6.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    'Red_Hat_Linux_6.1'         , '6.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '6.2EE'                     , '6.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '6.2.2'                     , '6.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '6.2de'                     , '6.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '6.2fr'                     , '6.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '6.2es'                     , '6.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '6.2it'                     , '6.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '6.2ja'                     , '6.2');

-- and now for the junk mappings...
insert into rhnRedHatCanonVersion (version, canon_version) values (
    'Red Hat Linux 7.2'         , '7.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    'Red Hat Linux 7.2 i386'    , '7.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    'redhat-linux-i686-7.0'     , '7.0');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    'Red_Hat_Linux_7.2'         , '7.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '6.2-1'			, '6.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.0.98'			, '7.1');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.1.90'			, '7.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.1.90EE'			, '7.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.1.91AS'			, '7.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.1.93'			, '7.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.1.94'			, '7.2');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.2.93'                    , '7.3');
insert into rhnRedHatCanonVersion (version, canon_version) values (
    '7.2.94'                    , '7.3');

commit;

--
-- Revision 1.2  2002/05/06 02:59:46  misa
-- Added the beta channels
--
-- Revision 1.1  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
