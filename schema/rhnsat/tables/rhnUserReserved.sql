--
-- $Id$
--

create table
rhnUserReserved
(
	login		varchar2(64)
			constraint rhn_user_res_login_nn not null,
	login_uc	varchar2(64)
			constraint rhn_user_res_login_uc_nn not null,
	password	varchar2(38)
			constraint rhn_user_res_pwd_nn not null,
        created         date default(sysdate)
			constraint rhn_user_res_created_nn not null,
        modified        date default(sysdate)
			constraint rhn_user_res_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_user_res_login_uc_uq
	on rhnUserReserved(login_uc)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_user_res_mod_trig
before insert or update on rhnUserreserved
for each row
begin
	:new.login_uc := upper(:new.login);
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.9  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.8  2002/06/11 17:07:04  cturner
-- update from misa
--
-- Revision 1.7  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
