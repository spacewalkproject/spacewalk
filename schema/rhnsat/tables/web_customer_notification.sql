--
-- $Id$
--

create sequence web_cust_notif_seq start with 1000000;

create table
web_customer_notification
(
	id			number
				constraint web_cust_not_id_nn not null
				constraint web_cust_not_id_pk primary key
					using index tablespace [[64k_tbs]],
	org_id			number
				constraint web_cust_not_oid_nn not null
				constraint web_cust_not_oid_fk
					references web_customer(id)
					on delete cascade,
	contact_email_address	varchar2(150)
				constraint web_cust_not_ea_nn not null,
	creation_date		date
				constraint web_cust_not_creat_nn not null
)
	organization heap
	storage ( freelists 16 )
	enable row movement
	initrans 32
	nocache nomonitoring;

--
-- $Log$
-- Revision 1.3  2003/10/20 15:07:05  pjones
-- bugzilla: none -- cleanup that has been needed for quite some time
--
