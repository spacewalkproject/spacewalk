--
-- $Id$
--

create table
rhnChannelFamily
(
	id		number
			constraint rhn_channel_family_id_nn not null
			constraint rhn_channel_family_id_pk primary key
				using index tablespace [[64k_tbs]],
	org_id		number
			constraint rhn_channel_family_org_fk
				references web_customer(id)
				on delete cascade,
	name		varchar2(128)
			constraint rhn_channel_family_name_nn not null,
	label		varchar2(128)
			constraint rhn_channel_family_label_nn not null,
	product_url     varchar2(128) default 'http://www.redhat.com/products/'
			constraint rhn_channel_family_url_nn not null,
	created		date default (sysdate)
			constraint rhn_channel_family_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_channel_family_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_channel_family_id_seq start with 1000;

create unique index rhn_channel_family_label_uq
	on rhnChannelFamily(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_channel_family_name_uq
	on rhnChannelFamily(name)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_channel_family_mod_trig
before insert or update on rhnChannelFamily
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.20  2003/04/11 20:46:21  cturner
-- bugzilla: 85923.  begone purchasable flag
--
-- Revision 1.19  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.18  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.17  2002/03/19 22:41:30  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.16  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
