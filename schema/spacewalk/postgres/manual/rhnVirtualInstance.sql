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
rhnVirtualInstance
(
	id			numeric not null
				constraint rhn_vi_id_pk primary key,
--				using index tablespace [[64k_tbs]],
	host_system_id		numeric
				constraint rhn_vi_hsi_fk
				references rhnServer(id),
	virtual_system_id	numeric
				constraint rhn_vi_vsi_fk
				references rhnServer(id),
	uuid			varchar(128),
        confirmed               numeric(1) default 1 not null,
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null
)
;

create sequence rhn_vi_id_seq;

create index rhn_vi_hsid_vsid_idx
	on rhnVirtualInstance(host_system_id, virtual_system_id)
--      tablespace [[64k_tbs]]
  ;

create index rhn_vi_vsid_hsid_idx
	on rhnVirtualInstance(virtual_system_id, host_system_id)
--	tablespace [[64k_tbs]]
  ;

--
