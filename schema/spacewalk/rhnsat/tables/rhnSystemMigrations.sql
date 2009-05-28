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

create table
rhnSystemMigrations
(
        org_id_to       number
                        constraint rhn_sys_mig_oidto_fk
                                references web_customer(id)
                                on delete set null,
        org_id_from     number
                        constraint rhn_sys_mig_oidfrm_fk
                                references web_customer(id)
                                on delete set null,
        server_id       number
                        constraint rhn_sys_mig_sid_nn not null
                        constraint rhn_sys_mig_sid_fk
                                references rhnServer(id)
                                 on delete cascade,
        migrated        date default (sysdate)
                        constraint rhn_sys_mig_migrated_nn not null
)
        enable row movement
  ;

create index rsm_org_id_to_idx
        on rhnSystemMigrations ( org_id_to )
  ;


create index rsm_org_id_from_idx
        on rhnSystemMigrations ( org_id_from )
  ;
