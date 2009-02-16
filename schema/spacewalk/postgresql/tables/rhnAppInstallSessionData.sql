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

create sequence rhn_appinst_sdata_id_seq;

create table
rhnAppInstallSessionData
(
	id		numeric not null constraint rhn_appinst_sdata_id_pk primary key ,
	session_id	numeric	not null constraint rhn_appinst_sdata_sid_fk references rhnAppInstallSession(id) 
			on delete cascade,
	key		varchar(64)  not null,
	value		varchar(2048),
	extra_data	bytea,
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null,
	constraint rhn_appinst_sdata_sid_k_uq unique ( session_id, key )
)
--	tablespace [[blob]]
  ;



create index rhn_appinst_sdata_id_idx
	on rhnAppInstallSessionData( id )
--	tablespace [[2m_tbs]]
  ;

create index rhn_appinst_sdata_sid_k_id_idx
	on rhnAppInstallSessionData( session_id, key, id )
--	tablespace [[8m_tbs]]
  ;

