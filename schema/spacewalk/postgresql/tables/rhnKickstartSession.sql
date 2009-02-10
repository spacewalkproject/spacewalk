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

create sequence rhn_ks_session_id_seq;

create table
rhnKickstartSession
(
	id			numeric not null
				constraint rhn_ks_session_id_pk primary key
--					using index tablespace [[8m_tbs]],
	kickstart_id		numeric
				constraint rhn_ks_session_ksid_fk
					references rhnKSData(id)
					on delete cascade,
        kickstart_mode          varchar(32),
	kstree_id               numeric
				constraint rhn_ks_session_kstid_fk
				        references rhnKickstartableTree(id)
					on delete set null,
	org_id			numeric not null
				constraint rhn_ks_session_oid_fk
					references web_customer(id)
					on delete cascade,
    	scheduler               numeric
	    	    	    	constraint rhn_ks_session_sched_fk
				    	references web_contact(id)
					on delete set null,
	old_server_id		numeric
				constraint rhn_ks_session_osid_fk
					references rhnServer(id),
	new_server_id		numeric
				constraint rhn_ks_session_nsid_fk
					references rhnServer(id),
	host_server_id		numeric
				constraint rhn_ks_session_hsid_fk
					references rhnServer(id)
                                        on delete cascade,
	action_id		numeric
				constraint rhn_ks_session_aid_fk
					references rhnAction(id)
					on delete set null,
	state_id		numeric not null
				constraint rhn_ks_session_ksssid_fk
					references rhnKickstartSessionState(id),
	server_profile_id	numeric
				constraint rhn_ks_session_spid_fk
					references rhnServerProfile(id)
					on delete set null,
	last_action		timestamp default (current_timestamp) not null,
        package_fetch_count     numeric default 0 not null,
        last_file_request       varchar(2048),
    	system_rhn_host         varchar(256),
	kickstart_from_host	varchar(256),
	deploy_configs		char(1) default('N') not null,
        virtualization_type     numeric not null
	                        constraint rhn_kss_kvt_fk
				        references rhnKickstartVirtualizationType(id)
					on delete set null,
    client_ip        		varchar(15),
	created			timestamp default (current_timestamp) not null,
	modified		timestamp default (current_timestamp) not null
)
  ;

create index rhn_ks_session_oid_idx
	on rhnKickstartSession( org_id )
--	tablespace [[8m_tbs]]
  ;

create index rhn_ks_session_osid_aid_idx
	on rhnKickstartSession( old_server_id, action_id )
--	tablespace [[4m_tbs]]
  ;

create index rhn_ks_session_nsid_idx
	on rhnKickstartSession( new_server_id )
--	tablespace [[4m_tbs]]
  ;

create index rhn_ks_session_hsid_idx
	on rhnKickstartSession( host_server_id )
--	tablespace [[4m_tbs]]
  ;

--
--
-- Revision 1.20  2004/04/08 20:37:36  pjones
-- bugzilla: 113914 -- add "deploy_configs" option to kickstart sessions
--
-- Revision 1.19  2004/04/08 15:46:12  pjones
-- bugzilla: 113290 -- add "kickstart_from_host" column to rhnKickstartSession
--
-- Revision 1.18  2004/01/19 22:23:23  pjones
-- bugzilla: none -- more index creation fixes on rhn_ks_session_oid_idx
--
-- Revision 1.17  2004/01/19 18:03:17  pjones
-- bugzilla: none -- these can go away, since we're deleting them in all of
-- the delete_server* procs.
--
-- Revision 1.16  2004/01/07 20:15:59  pjones
-- bugzilla: 113047 -- don't kill the kickstart session when the server
-- profile goes away
--
-- Revision 1.15  2003/12/19 18:48:54  rnorwood
-- bugzilla: 111966 - use rhnServerPath data to pick the correct proxy server for a kickstarting box.
--
-- Revision 1.14  2003/11/24 17:24:53  misa
-- Changing fk for rhnServer to on delete set null
--
-- Revision 1.13  2003/11/21 21:38:31  misa
-- Schema change to track both old and new servers
--
-- Revision 1.12  2003/11/11 21:03:12  pjones
-- bugzilla: 109064 -- index needs to exist, but not be unique
--
-- Revision 1.11  2003/11/07 22:41:12  pjones
-- bugzilla: 109064
-- don't really need this index
--
-- Revision 1.10  2003/11/04 22:31:25  pjones
-- bugzilla: 109064 -- rhnKickstartAction(server_id, action_id) should be
-- unique
--
-- Revision 1.9  2003/10/24 03:40:35  cturner
-- add last file requested and total file request count to ks session
--
-- Revision 1.8  2003/10/15 20:11:12  pjones
-- bugzilla: 106951
-- rhnKickstartSessionHistory, per robin's request
--
-- Revision 1.7  2003/10/15 02:06:46  rnorwood
-- bugzilla: 106068 - first pass at kickstart status pages.
--
-- Revision 1.6  2003/10/14 15:24:38  rnorwood
-- bugzilla: 106063 - get rid of uniqueness of kickstart sessions - fail the old ones instead.
--
-- Revision 1.5  2003/10/13 21:59:23  rnorwood
-- bugzilla: 106063 - web flow for kickstarting actually works now - yah!  Some warnings left in for debug purposes.
--
-- Revision 1.4  2003/10/08 19:29:45  rnorwood
-- bugzilla: 106581 - make kickstart_id NULLable, and set action_id NULL when an action is deleted instead of on delete cascade.
--
-- Revision 1.3  2003/10/08 19:23:09  pjones
-- bugzilla: none
--
-- change the constraint/trigger/sequence names again, this time less
-- consistant with everywhere else, but a lot more palitable
--
-- Revision 1.2  2003/10/08 18:51:44  pjones
-- bugzilla: none
--
-- Clean up the rhnKickstartSession stuff a bit.
--
