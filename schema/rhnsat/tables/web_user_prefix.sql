--
-- prefixes for web users, as used in satellite
--
-- $Id$
--

create table
web_user_prefix
(
	text			varchar2(12)
				constraint wup_text_nn not null
				constraint wup_text_pk primary key
)
	enable row movement
	;

insert into WEB_USER_PREFIX values (' ');
insert into WEB_USER_PREFIX values ('.');
insert into WEB_USER_PREFIX values ('Mr.');
insert into WEB_USER_PREFIX values ('Mrs.');
insert into WEB_USER_PREFIX values ('Miss');
insert into WEB_USER_PREFIX values ('Ms.');
insert into WEB_USER_PREFIX values ('Dr.');
insert into WEB_USER_PREFIX values ('Hr.');
insert into WEB_USER_PREFIX values ('Sr.');

