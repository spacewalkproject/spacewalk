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

insert into rhnServerProfileType(id, label, name) values (
	rhn_sproftype_id_seq.nextval, 'normal',
	'A normal server profile');

insert into rhnServerProfileType(id, label, name) values (
	rhn_sproftype_id_seq.nextval, 'sync_profile',
	'A server profile associated with a package sync');

commit;
--
--
-- Revision 1.1  2003/11/12 04:55:26  cturner
-- bugzilla: 109080, schema for server profile types
--
