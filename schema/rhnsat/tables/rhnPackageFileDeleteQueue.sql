--
-- $Id: rhnPackageFileDeleteQueue.sql
--

create table
rhnPackageFileDeleteQueue
(
        path            varchar2(1000),
	created			date default(sysdate)
				constraint rhn_pfdqueue_created_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

alter table rhnPackageFileDeleteQueue add constraint rhn_pfdqueue_path_uq
	unique ( path );

