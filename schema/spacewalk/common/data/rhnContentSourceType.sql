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
--

insert into rhnContentSourceType (id, label) values
(sequence_nextval('rhn_content_source_type_id_seq'), 'yum');
insert into rhnContentSourceType (id, label) values
(sequence_nextval('rhn_content_source_type_id_seq'), 'uln');
insert into rhnContentSourceType (id, label) values
(sequence_nextval('rhn_content_source_type_id_seq'), 'deb');
