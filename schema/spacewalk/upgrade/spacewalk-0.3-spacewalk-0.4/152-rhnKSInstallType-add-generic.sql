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

insert into rhnKSInstallType (id, label, name)
        values (rhn_ksinstalltype_id_seq.nextval,
                'fedora_8','Fedora 8'
        );

insert into rhnKSInstallType (id, label, name)
        values (rhn_ksinstalltype_id_seq.nextval,
                'fedora_10','Fedora 10'
        );

insert into rhnKSInstallType (id, label, name)
        values (rhn_ksinstalltype_id_seq.nextval,
                'generic_rpm','Generic RPM'
        );

show errors

-- $Log$
-- Revision 1  2009/01/06 16:51 mmccune
-- Add cobbler_id column

