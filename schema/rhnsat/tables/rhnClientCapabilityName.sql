--
-- $Id$
-- 

create table
rhnClientCapabilityName
(
	id		number
			constraint rhn_clientcapnam_id_nn not null
			constraint rhn_clientcapnam_id_pk primary key 
				using index tablespace [[8m_tbs]],
	name		varchar2(32)
			constraint rhn_clientcapnam_name_nn not null
			constraint rhn_clientcapnam_name_unq unique
) 
	storage (freelists 16 )
	initrans 32;

create sequence rhn_client_capname_id_seq;

-- $Log$
-- Revision 1.1  2003/07/21 22:11:44  misa
-- bugzilla: none  More normalization; s/value/version/
--
