-- Indices for web_contact
--
-- $Id$

create index web_contact_oid_id
	on web_contact(org_id, id)
	parallel 6
	tablespace [[web_index_tablespace_2]]
	storage(pctincrease 1);
	
create index web_contact_id_oid_cust_luc on
	web_contact(id,oracle_contact_id,org_id,login_uc)
	parallel 6
	tablespace [[web_index_tablespace_2]]
	storage(pctincrease 1);

--create unique index web_contact_utf_name_filter on
--    	web_contact(convert(login, 'WE8ISO8859P1'))
--	parallel 6
--	tablespace [[web_index_tablespace_2]]
--	storage(pctincrease 1 );

-- $Log$
-- Revision 1.9  2002/09/27 15:17:22  misa
-- satcon-deploy-tree is not that clever to ignore comments, so it bitches about undefined tags
--
-- Revision 1.8  2002/05/09 06:20:48  gafton
-- disable hacked up index for the satellite stuff
--
