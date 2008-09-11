--
-- $Id$
--
-- list of available timezones and the string to use to display them

create sequence rhn_timezone_id_seq start with 7000 order;

create table 
rhnTimezone
(
        id              number
			constraint rhn_timezone_id_nn not null,
        olson_name      varchar2(128)
	    	    	constraint rhn_timezone_olson_nn not null,
	display_name    varchar2(128)
	    	    	constraint rhn_timezone_display_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_timezone_id_idx
	on rhnTimezone( id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnTimezone add constraint rhn_timezone_id_pk
	primary key ( id );

create unique index rhn_timezone_olson_uq
	on rhnTimezone(olson_name);

create unique index rhn_timezone_display_uq
	on rhnTimezone(display_name);
