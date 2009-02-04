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

create sequence rhn_confchan_id_seq;

create table
rhnConfigChannel
(
	id			numeric not null
				constraint rhn_confchan_id_pk primary key
--					using index tablespace [[2m_tbs]]
					,
	org_id			numeric not null
				constraint rhn_confchan_oid_fk
					references web_customer(id),
	confchan_type_id	numeric not null
				constraint rhn_confchan_ctid_fk
					references rhnConfigChannelType(id),
	name			varchar(128) not null,
	label			varchar(64) not null,
	description		varchar(1024) not null,
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null,

	constraint rhn_confchan_oid_label_type_uq unique ( org_id, label, confchan_type_id )
--		using index tablespace [[4m_tbs]]
);

