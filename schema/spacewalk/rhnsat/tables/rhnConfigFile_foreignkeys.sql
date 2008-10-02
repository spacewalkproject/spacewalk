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
-- This needs to be in a seperate file because the tables
-- have a circular reference.

alter table rhnConfigFile add constraint rhn_conffile_lcrid_fk
	foreign key ( latest_config_revision_id )
	references rhnConfigRevision(id)
	on delete set null;

--
--
-- Revision 1.2  2003/11/14 21:16:07  pjones
-- bugzilla: 110094 -- make rhnConfigRevision deletable.  We need to figure out
-- the best way to repopulate this...
--
-- Revision 1.1  2003/11/10 20:26:05  pjones
-- bugzilla: none -- break rhnConfigFile's fk to rhnConfigRevision out into
-- another file, so we can build the circular dep
--
