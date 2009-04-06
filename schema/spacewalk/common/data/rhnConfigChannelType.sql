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

insert into rhnConfigChannelType(id, label, name, priority) values (
	rhn_confchantype_id_seq.nextval, 'normal',
	'A general purpose configuration channel', 1);

insert into rhnConfigChannelType(id, label, name, priority) values (
	rhn_confchantype_id_seq.nextval, 'local_override',
	'Files on disk win', 0);

insert into rhnConfigChannelType(id, label, name, priority) values (
	rhn_confchantype_id_seq.nextval, 'server_import',
	'Files imported from the server', 2);

commit;
--
--
-- Revision 1.3  2003/11/10 10:19:42  cturner
-- fix forgotten column when adding values
--
-- Revision 1.2  2003/11/09 20:50:38  cturner
-- toss priority back in... no idea if this is right or not. pjones, please berate me if not :)
--
-- Revision 1.1  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
--
