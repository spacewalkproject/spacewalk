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
-- data for rhnVirtualInstanceEventType

insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Create', 'create');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Destroy', 'destroy');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Shutdown', 'shutdown');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Pause', 'pause');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Unpause', 'unpause');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Migrate', 'migrate');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Vcpu-Set', 'vcpu-set');
insert into rhnVirtualInstanceEventType (id, name, label) values (rhn_viet_id_seq.nextval, 'Mem-Set', 'mem-set');
