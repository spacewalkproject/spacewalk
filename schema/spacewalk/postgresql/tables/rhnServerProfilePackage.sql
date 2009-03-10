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
rhnServerProfilePackage
(
        server_profile_id       numeric
	    	    	    	not null
	    	    	    	constraint rhn_sprofile_spid_fk
				    	references rhnServerProfile(id)
					on delete cascade,
        name_id                 numeric
	    	    	    	not null
	    	    	    	constraint rhn_sprofile_nid_fk
				    	references rhnPackageName(id),
        evr_id                  numeric 
	    	    	    	not null
	    	    	    	constraint rhn_sprofile_evrid_fk
					references rhnPackageEvr(id),
        package_arch_id         numeric
                                constraint rhn_sprofile_package_fk
                                        references rhnPackageArch(id)
)
  ;

create index rhn_sprof_sp_sne_idx on
        rhnServerProfilePackage(server_profile_id, name_id, evr_id)
--	tablespace [[64k_tbs]]
	;

--
-- Revision 1.7 2008/11/24
-- bugzilla: 456532 -- adding package_arch_id
--
-- Revision 1.6  2003/10/07 14:12:49  pjones
-- bugzilla: none -- cascade deps on rhnServerProfilePackage to make deletes
-- simpler
--
-- Revision 1.5  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.4  2002/11/08 17:20:58  pjones
-- update these as they're apparently actually going to be used.
-- This version does the PK index the "new" way, which we should use going
-- forward.
--
-- Revision 1.3  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
