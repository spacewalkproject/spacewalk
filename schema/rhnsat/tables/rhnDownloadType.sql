--
-- $Id$
--

create table
rhnDownloadType
(
	id		number
			constraint rhn_download_type_id_nn not null
			constraint rhn_download_type_pk primary key,
	label		varchar2(48)
			constraint rhn_download_type_label_nn not null,
	name		varchar2(96)
			constraint rhn_download_type_name_nn not null
);
	
create unique index rhn_download_type_label_uq
	on rhnDownloadType(label);
create unique index rhn_download_type_name_uq
	on rhnDownloadType(name);

-- $Log$
-- Revision 1.1  2003/08/04 17:20:54  bretm
-- bugzilla:  98685
--
-- tables + grants + synonyms for reorg of channel/iso downloadsx
--
