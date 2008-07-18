--
-- $id$
--
-- data from /etc/sysconfig/installinfo

create table
rhnServerInstallInfo
(
	id		number
			constraint rhn_server_install_info_id_nn not null
			constraint rhn_server_install_info_id_pk primary key
				using index tablespace [[2m_tbs]],
        server_id       number
                        constraint rhn_server_install_info_sid_nn not null
                        constraint rhn_server_install_info_sid_fk
                                references rhnServer(id),
	install_method	varchar2(32)
			constraint rhn_server_install_info_im_nn not null,
	iso_status	number,
	mediasum	varchar2(64),
	created		date default(sysdate)
			constraint rhn_server_install_info_cr_nn not null,
	modified	date default(sysdate)
			constraint rhn_server_install_info_md_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_server_install_info_id_seq;

create index rhn_s_inst_info_sid_im_idx
	on rhnServerInstallInfo(server_id, install_method)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;


create unique index rhn_server_install_info_sid_uq
	on rhnServerInstallInfo( server_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_s_inst_info_mod_trig
before insert or update on rhnServerInstallInfo
for each row
begin
	:new.modified := sysdate;
end;
/

-- $Log$
-- Revision 1.4  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.3  2003/11/12 14:45:17  pjones
-- bugzilla: none -- put the unique in a different tablespace
--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/10/23 22:44:05  misa
-- Added schema for /etc/sysconfig/installinfo
--
