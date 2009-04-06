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

create sequence rhn_appinst_instance_id_seq;

create table
rhnAppInstallInstance
(
	id		numeric  not null constraint rhn_appinst_instance_id_pk primary key,
	name		varchar(128) not null,
	label		varchar(128)not null,
	version		varchar(32) not null,
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null,
	constraint rhn_appinst_instance_lv_uq unique ( label, version )
)
;

create index rhn_appinst_instance_id_idx
	on rhnAppInstallInstance( id )
--	tablespace [[4m_tbs]]
  ;
create index rhn_appinst_instance_lv_id_idx
	on rhnAppInstallInstance( label, version, id )
--	tablespace [[2m_tbs]]
  ;

