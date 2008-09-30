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

insert into rhnRelationshipType ( id, label, description ) values (
	rhn_reltype_id_seq.nextval, 'cloned_from',
	'was cloned from'
);

--
-- Revision 1.2  2003/03/05 18:18:48  rnorwood
-- bugzilla: 83783 - store and display the rhnchannelrelationship when a channel is cloned.
--
-- Revision 1.1  2003/03/03 17:11:58  pjones
-- progeny relationships for channel and errata
--
