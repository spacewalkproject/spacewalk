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
-- $Id$
--

update rhnKickstartVirtualizationType
    set label = 'xenpv' where label = 'para_guest';

update rhnKickstartVirtualizationType
    set label = 'auto' where label = 'none';

update rhnKickstartVirtualizationType
    set name = 'Auto' where label = 'auto';

update rhnKickstartVirtualizationType
    set name = 'XEN Para-Virtualized Guest' where label = 'xenpv';

insert into rhnKickstartVirtualizationType (id, name, label)
    values (rhn_kvt_id_seq.nextval, 'KVM Virtualized Guest', 'qemu');

insert into rhnKickstartVirtualizationType (id, name, label)
    values (rhn_kvt_id_seq.nextval, 'XEN Fully-Virtualized Guest', 'xenfv');

commit;

show errors

-- $Log$
-- Revision 1  2008/10/29 7:01:05  mmccune
-- add new kickstart_host for koan usage
