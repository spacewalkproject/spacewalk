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

create sequence rhn_appinst_session_id_seq;

create table
rhnAppInstallSession
(
	id		numeric not null constraint rhn_appinst_sessiond_id_pk	primary key,
	instance_id	numeric not null	constraint rhn_appinst_session_iid_fk
				references rhnAppInstallInstance(id)
				on delete cascade,
	md5sum		varchar(64),
	process_name	varchar(32),
	step_numeric	numeric,
	user_id		numeric not null
			constraint rhn_appinst_session_uid_fk
				references web_contact(id),
	server_id	numeric not null
			constraint rhn_appinst_session_sid_fk
				references rhnServer(id),
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null
)
  ;

create index rhn_appinst_session_id_iid_idx
	on rhnAppInstallSession( id, instance_id )
--	tablespace [[4m_tbs]]
  ;

create index rhn_appinst_session_iid_id_idx
    on rhnAppInstallSession( instance_id, id )
--    tablespace [[4m_tbs]]
  ;

create index rhn_appinst_sessn_uid_iid_idx
    on rhnAppInstallSession( user_id, instance_id )
--    tablespace [[4m_tbs]]
  ;

create index rhn_appinst_sessn_sid_iid_idx
    on rhnAppInstallSession( server_id, instance_id )
--    tablespace [[4m_tbs]]
  ;


