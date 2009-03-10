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
	nextval( 'rhn_confchantype_id_seq' ), 'normal',
	'A general purpose configuration channel', 1);

insert into rhnConfigChannelType(id, label, name, priority) values (
	nextval( 'rhn_confchantype_id_seq' ), 'local_override',
	'Files on disk win', 0);

insert into rhnConfigChannelType(id, label, name, priority) values (
	nextval( 'rhn_confchantype_id_seq' ), 'server_import',
	'Files imported from the server', 2);

