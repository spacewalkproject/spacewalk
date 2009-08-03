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

create sequence rhn_actionks_xenguest_id_seq;

create table
rhnActionKickstartGuest
(
	id			numeric not null
				constraint rhn_actionks_xenguest_aid_uq unique
--					 using index tablespace [[8m_tbs]]
				constraint rhn_actionks_xenguest_id_pk
					primary key,
	action_id		numeric not null
				constraint rhn_actionks_xenguest_aid_fk
					references rhnAction(id)
					on delete cascade,
	append_string		varchar(1024),
        ks_session_id           numeric
                                constraint rhn_actionks_xenguest_ksid_fk
                                        references rhnKickstartSession(id)
                                        on delete cascade,
	guest_name		varchar(256),
	mem_kb			numeric, 
	vcpus			numeric,
	disk_gb			numeric,
        cobbler_system_name	varchar(256),
        disk_path		varchar(256),
        virt_bridge		varchar(256),
        kickstart_host          varchar(256),
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null
);

create index rhn_actionks_xenguest_id_idx
	on rhnActionKickstartGuest( id )
--	tablespace [[4m_tbs]]
;

