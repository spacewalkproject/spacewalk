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
-- $Id$
--

create sequence rhn_conffile_failure_id_seq;

create table
rhnConfigFileFailure
(
	id			number
				constraint rhn_conffile_fail_id_nn not null
				constraint rhn_conffile_fail_id_pk 
					primary key 
					using index tablespace [[64k_tbs]],
	label			varchar2(64)
				constraint rhn_conffile_fail_label_nn not null
				constraint rhn_conffile_fail_label_uq unique
					using index tablespace [[64k_tbs]],
	name			varchar2(256)
				constraint rhn_conffile_fail_name_nn not null
				constraint rhn_conffile_fail_name_uq unique
					using index tablespace [[64k_tbs]],
	created			date default(sysdate)
				constraint rhn_conffile_fail_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_conffile_fail_mod_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_conffile_fail_mod_trig
before insert or update on rhnConfigFileFailure
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.2  2004/01/16 15:28:14  pjones
-- bugzilla: 113353
-- 310.1.rhn.sql:
--   fix typos
--   reenable kickstart-package-sync.1.rhn.sql
--   move triggers to much latter
--   add lookup_cf_state and lookup_first_matching_cf
-- 310.2.rhnuser.sql:
--   fix typos
--   add lookup_cf_state and lookup_first_matching_cf
-- configchannel.1.rhn.sql:
--   move triggers to near the end
--   add rhnConfigFileFailure
--   fix typos
--   add rhnOrgQuota
-- configchannel.2.rhnuser.sql:
--   add comments about which synonyms don't really exist
--   add rhnConfigFileFailure
-- configfilename_failure.2.rhnuser.sql:
--   add rhnConfigFileFailure
-- kickstart-name-unique-109057.1.rhn.sql:
--   add comment about how one org's rhnKSData isn't unique (fixed data by hand)
-- kickstart-package-sync.1.rhn.sql:
--   make indices for new *_server_id columns instead of server_id
-- kickstart-session-old-new-server.2.rhn.sql:
--   make this script actually work
-- kstree-type.1.rhn.sql:
--   added commit
-- server-profile-type.1.rhn.sql:
--   added commit
--   reformatted constraint changes
-- rhnConfigFileFailure.sql:
--   fixed table and constraint name
--
-- Revision 1.1  2003/11/15 01:45:33  misa
-- bugzilla: 107284  Schema for storing missing files
--
--
