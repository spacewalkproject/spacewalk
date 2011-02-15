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
-- data for rhnVirtualInstanceEventType

insert into rhnVirtualInstanceEventType (id, name, label) values (sequence_nextval('rhn_viet_id_seq'), 'Create', 'create');
insert into rhnVirtualInstanceEventType (id, name, label) values (sequence_nextval('rhn_viet_id_seq'), 'Destroy', 'destroy');
insert into rhnVirtualInstanceEventType (id, name, label) values (sequence_nextval('rhn_viet_id_seq'), 'Shutdown', 'shutdown');
insert into rhnVirtualInstanceEventType (id, name, label) values (sequence_nextval('rhn_viet_id_seq'), 'Pause', 'pause');
insert into rhnVirtualInstanceEventType (id, name, label) values (sequence_nextval('rhn_viet_id_seq'), 'Unpause', 'unpause');
insert into rhnVirtualInstanceEventType (id, name, label) values (sequence_nextval('rhn_viet_id_seq'), 'Migrate', 'migrate');
insert into rhnVirtualInstanceEventType (id, name, label) values (sequence_nextval('rhn_viet_id_seq'), 'Vcpu-Set', 'vcpu-set');
insert into rhnVirtualInstanceEventType (id, name, label) values (sequence_nextval('rhn_viet_id_seq'), 'Mem-Set', 'mem-set');
