-- $Id$
--
-- XXX this should be on production, but I'm temporarily killing it just to
-- see how far the imports get
-- EXCLUDE: all

create table
responsysUsers
(
	web_user_id  number
			constraint responsys_users_nn not null
			constraint responsys_users_unq unique
			constraint responsys_users_fk
				references web_user_contact_permission(web_user_id) on delete cascade,
	email_allowed	char(1)
			constraint responsys_users_ea_nn not null
			constraint responsys_users_ea_ck
				check (email_allowed in ('Y','N')),
	processed	char(1)
			constraint responsys_users_p_nn not null
			constraint responsys_users_p_ck
				check (processed in ('Y','N')),
	created		date default(sysdate)
			constraint responsys_users_created_nn not null,
	modified	date default(sysdate)
			constraint responsys_users_modified not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

update web_user_contact_permission set email = 'N' where email is null;
commit;
insert into responsysUsers (
	select web_user_id, email, 'N',sysdate,sysdate from 
		web_user_contact_permission
);
commit;

create or replace trigger
wucp_update_responsys
after insert or update
on web_user_contact_permission
for each row
declare
	user_exists	number;
begin
	select count(*) into user_exists from responsysUsers where
		web_user_id = :new.web_user_id;
	if user_exists = 0 then
		insert
			into responsysUsers
			values (:new.web_user_id,:new.email,
				'N',sysdate,sysdate);
	else
		update responsysUsers
			set email_allowed = :new.email,
			    modified = sysdate
			where web_user_id = :new.web_user_id;
	end if;
end;
/
show errors

create or replace view
responsysNewUsers as
	select
		wupi.email,
		wupi.first_names,
		wupi.last_name,
		wupi.company,
		wusi.address1,
		wusi.address2,
		wusi.city,
		wusi.state,
		wusi.zip,
		wusi.phone,
		ru.web_user_id
	from
		responsysUsers ru,
		web_user_personal_info wupi,
		web_user_site_info wusi
	where
		ru.email_allowed = 'Y' and
		ru.processed = 'N' and
		ru.web_user_id = wupi.web_user_id and
		ru.web_user_id = wusi.web_user_id and
		wusi.type = 'M'
;


-- $Log$
-- Revision 1.6  2003/02/18 16:08:49  pjones
-- cascades for delete_user
--
-- Revision 1.5  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.4  2002/05/09 20:52:41  pjones
-- these don't need get imported currently.
-- eventually, ResponsysUsers* should.
--
-- Revision 1.3  2002/05/08 23:10:12  gafton
-- Make file exclusion work correctly
--
