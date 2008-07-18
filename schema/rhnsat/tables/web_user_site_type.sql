-- Site Type
--
-- $Id$
--

create table
web_user_site_type
(
	type			char(1)
				constraint wust_type_nn not null
				constraint wust_type_pk primary key,
	description		varchar2(64)
				constraint wust_desc_nn not null
)
	enable row movement
	;

insert into WEB_USER_SITE_TYPE VALUES('M', 'MARKET');
insert into WEB_USER_SITE_TYPE VALUES('B', 'BILL_TO');
insert into WEB_USER_SITE_TYPE VALUES('S', 'SHIP_TO');
insert into WEB_USER_SITE_TYPE VALUES('R', 'SERVICE');

-- $Log$
-- Revision 1.2  2002/05/09 05:37:31  gafton
-- re-unify again
--
-- Revision 1.1  2002/02/13 16:20:43  pjones
-- commit these here
--
