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
alter table rhnServerPackage modify server_id
	constraint rhn_serverpackage_sid_nn not null;

alter table rhnServerPackage modify name_id
	constraint rhn_serverpackage_nid_nn not null;

alter table rhnServerPackage modify evr_id
	constraint rhn_serverpackage_eid_nn not null;

alter table rhnServerPackage
	add constraint rhn_serverpackage_sid_fk
	foreign key (server_id) references rhnServer(id) on delete cascade;

alter table rhnServerPackage
	add constraint rhn_serverpackage_nid_fk
	foreign key (name_id) references rhnPackageName(id);

alter table rhnServerPackage
	add constraint rhn_serverpackage_eid_fk
	foreign key (evr_id) references rhnPackageEVR(id);

alter table rhnServerPackage
   add constraint rhn_serverpackage_paid_fk
   foreign key (package_arch_id) references rhnPackageArch(id);
