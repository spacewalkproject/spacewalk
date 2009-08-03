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

insert into rhnOrgChannelSettingsType ( id, label )
	values ( rhn_ocstngs_type_id_seq.nextval, 'not_globally_subscribable' );

commit;

--
-- Revision 1.2  2003/07/25 18:18:52  cturner
-- missing reference to data for rhnOrgChannelSettingsType
--
-- Revision 1.1  2003/07/17 18:07:18  pjones
-- bugzilla: none
--
-- change this to be the new way which was discussed
--
