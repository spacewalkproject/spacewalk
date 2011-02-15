--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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

insert into rhnErrataFileType ( id, label )
	values ( sequence_nextval('rhn_erratafile_type_id_seq'), 'RPM' );
insert into rhnErrataFileType ( id, label )
	values ( sequence_nextval('rhn_erratafile_type_id_seq'), 'SRPM' );
insert into rhnErrataFileType ( id, label )
	values ( sequence_nextval('rhn_erratafile_type_id_seq'), 'IMG' );
insert into rhnErrataFileType ( id, label )
	values ( sequence_nextval('rhn_erratafile_type_id_seq'), 'OVAL' );


--
-- Revision 1.1  2003/03/11 00:37:16  pjones
-- bugzilla: 85516
--
-- public errata schema checkin
--
-- bretm, you owe me cookies.
--
