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
--/

CREATE TABLE
rhnChannelFamilyLicenseConsent
(
        channel_family_id   numeric
			    not null
    	    	    	    constraint rhn_cfl_consent_cfid_fk
                            references rhnChannelFamily(id) on delete cascade,
    	user_id             numeric
	    	       	    not null
			    constraint rhn_cfl_consent_uid_fk
			    references web_contact(id) on delete cascade,
	server_id           numeric
			    not null
			    constraint rhn_cfl_consent_sid_fk
			    references rhnServer(id),
       	created		    date default (current_date)
			    not null,
	modified	    date default (current_date)
			    not null,
                            constraint rhn_cfl_consent_cf_s_uq
                            unique(channel_family_id, server_id)
--                          using index tablespace [[64k_tbs]]
)
  ;

create index rhn_cfl_consent_uid_idx
	on rhnChannelFamilyLicenseConsent ( user_id )
--	tablespace [[64k_tbs]]
	;

create index rhn_cfl_consent_sid_idx
	on rhnChannelFamilyLicenseConsent( server_id )
--	tablespace [[8m_tbs]]
	;

/*
create or replace trigger
rhn_cfl_consent_mod_trig
before insert or update on rhnChannelFamilyLicenseConsent
for each row
begin
        :new.modified := sysdate;
end;
/
SHOW ERRORS;
*/

--
-- Revision 1.10  2004/03/04 20:23:28  pjones
-- bugzilla: none -- diffs from dev and qa
--
-- Revision 1.9  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.8  2003/03/29 13:29:00  misa
-- bugzilla: none  Typo
--
-- Revision 1.7  2003/03/27 21:10:23  pjones
-- indices to support faster user deletion
--
-- Revision 1.6  2003/02/18 16:08:49  pjones
-- cascades for delete_user
--
-- Revision 1.5  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.4  2002/10/17 20:12:02  pjones
-- fix server delete for this case
--
-- Revision 1.3  2002/10/09 14:15:57  cturner
-- fix for broken trigger creation in rhnChannelFamilyLicense.sql and rhnChannelFamilyLicenseConsent.sql
--
-- Revision 1.2  2002/09/20 19:21:58  bretm
-- o  more 3rd party channel stuff...
--
-- Revision 1.1  2002/09/12 20:33:59  bretm
-- o  stuff for the bea channel
--
