--
-- $Id$
--

create table
rhnKickstartTimezone
(
	id			number
				constraint rhn_ks_timezone_id_nn not null
				constraint rhn_ks_timezone_pk primary key
					using index tablespace [[64k_tbs]],
	label			varchar2(128)
				constraint rhn_ks_timezone_label_nn not null,
	name			varchar2(128)
				constraint rhn_ks_timezone_name_nn not null,
	install_type            number
				constraint rhn_ks_timezone_it_nn not null
				constraint rhn_ks_timezone_it_fk
				    references rhnKSInstallType(id)
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;
	
create sequence rhn_ks_timezone_id_seq;
	
create unique index rhn_ks_timezone_it_label_uq
	on rhnKickstartTimezone(install_type, label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
create unique index rhn_ks_timezone_it_name_uq
	on rhnKickstartTimezone(install_type, name)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
