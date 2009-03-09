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
-- Indices for web_contact
--
--

create index web_contact_oid_id
	on web_contact(org_id, id)
	tablespace [[web_index_tablespace_2]]
  ;
	
create index web_contact_id_oid_cust_luc on
	web_contact(id,oracle_contact_id,org_id,login_uc)
	tablespace [[web_index_tablespace_2]]
  ;

--create unique index web_contact_utf_name_filter on
--    	web_contact(convert(login, 'WE8ISO8859P1'))
--	parallel 6
--	tablespace [[web_index_tablespace_2]]
--	storage(pctincrease 1 );

--
-- Revision 1.9  2002/09/27 15:17:22  misa
-- satcon-deploy-tree is not that clever to ignore comments, so it bitches about undefined tags
--
-- Revision 1.8  2002/05/09 06:20:48  gafton
-- disable hacked up index for the satellite stuff
--
