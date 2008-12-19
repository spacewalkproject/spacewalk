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
rhnServerProfile
(
        id              number
			constraint rhn_server_profile_id_nn not null,
        org_id          number
                        constraint rhn_server_profile_oid_nn not null
                        constraint rhn_server_profile_oid_fk
                                references web_customer(id)
				on delete cascade,
	base_channel    number
	    	    	constraint rhn_server_profile_bcid_nn not null
	    	    	constraint rhn_server_profile_bcid_fk
			    	references rhnChannel(id),
        name            varchar2(128),
        description     varchar2(256),
        info            varchar2(128),
	profile_type_id number
	    	    	constraint rhn_server_profile_ptype_nn not null
	    	    	constraint rhn_server_profile_ptype_fk
			    	references rhnServerProfileType(id),
        created         date default (sysdate)
			constraint rhn_server_profile_created_nn not null,
        modified        date default (sysdate)
			constraint rhn_server_profile_modified_nn not null
)
	enable row movement
  ;

create sequence rhn_server_profile_id_seq;

create unique index rhn_server_profile_noid_uq
    	on rhnServerProfile(org_id,name)
	tablespace [[64k_tbs]]
  ;

create index rhn_sprofile_id_oid_bc_idx
	on rhnServerProfile(id,org_id,base_channel)
	tablespace [[64k_tbs]]
  ;
alter table rhnServerProfile add
	constraint rhn_server_profile_id_pk primary key (id);

create index rhn_server_profile_o_id_bc_idx
	on rhnServerProfile(org_id,id,base_channel)
	tablespace [[64k_tbs]]
	nologging;

-- for channel deletion
create index rhn_server_profile_bc_idx
	on rhnServerProfile(base_channel)
	tablespace [[64k_tbs]]
	nologging;

--
-- Revision 1.12  2004/01/16 13:10:55  pjones
-- bugzilla: none -- make server deletion quick
--
-- Revision 1.11  2003/11/12 05:04:18  cturner
-- bugzilla: 109080, better column name... before it is too late!!!!!!!
--
-- Revision 1.10  2003/11/12 04:55:26  cturner
-- bugzilla: 109080, schema for server profile types
--
-- Revision 1.9  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.8  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.7  2002/12/13 19:49:10  cturner
-- first pass at conversion script
--
-- Revision 1.6  2002/11/08 17:20:58  pjones
-- update these as they're apparently actually going to be used.
-- This version does the PK index the "new" way, which we should use going
-- forward.
--
-- Revision 1.5  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
