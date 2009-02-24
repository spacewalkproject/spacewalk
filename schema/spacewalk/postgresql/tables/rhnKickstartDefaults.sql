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

create table
rhnKickstartDefaults
(
        kickstart_id            numeric
                                not null
                                constraint rhn_ksd_ksid_uq unique
                                constraint rhn_ksd_ksid_fk
                                references rhnKSData(id)
                                on delete cascade,
        kstree_id               numeric
                                not null
                                constraint rhn_ksd_kstid_fk
                                references rhnKickstartableTree(id)
                                on delete cascade,
        server_profile_id       numeric
                                constraint rhn_ksd_spid_fk
                                references rhnServerProfile(id)
                                on delete set null,
        cfg_management_flag     char(1) default ('Y')
                                not null
                                constraint rhn_ksd_cmf_ck
                                check (cfg_management_flag in ('Y','N')),
        remote_command_flag    char(1) default('N')
                               not null
                               constraint rhn_ksd_rmf_ck
                               check (remote_command_flag in ('Y','N')),
        virtualization_type    numeric
                               not null
                               constraint rhn_ksd_kvt_fk
                               references rhnKickstartVirtualizationType(id)
                               on delete set null,
        created                date default(current_date)
                               not null,
        modified               date default(current_date)
                               not null
)
  ;

create index rhn_ksd_kstid_idx
        on rhnKickstartDefaults( kstree_id )
 --     tablespace [[8m_tbs]]
        ;
/*
create or replace trigger
rhn_ksd_mod_trig
before insert or update on rhnKickstartDefaults
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.5  2004/05/24 20:28:00  pjones
-- bugzilla: 121395 -- add support for more than one default activation key
-- for a kickstart session
--
-- Revision 1.4  2004/03/02 21:55:02  pjones
-- bugzilla: 117292 -- add remote_command_flag
--
-- Revision 1.3  2004/01/12 16:54:16  pjones
-- bugzilla: 111701 -- add id tags and deps for rhnKickstartDefaults
--
