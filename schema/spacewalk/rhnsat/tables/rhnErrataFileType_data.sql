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

insert into rhnErrataFileType ( id, label )
	values ( rhn_erratafile_type_id_seq.nextval, 'RPM' );
insert into rhnErrataFileType ( id, label )
	values ( rhn_erratafile_type_id_seq.nextval, 'SRPM' );
insert into rhnErrataFileType ( id, label )
	values ( rhn_erratafile_type_id_seq.nextval, 'IMG' );

--
-- Revision 1.1  2003/03/11 00:37:16  pjones
-- bugzilla: 85516
--
-- public errata schema checkin
--
-- bretm, you owe me cookies.
--
