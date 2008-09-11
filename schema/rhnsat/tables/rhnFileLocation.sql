create table
rhnFileLocation
(
	file_id 	number
			constraint rhn_fileloc_fid_nn not null
			constraint rhn_fileloc_fid_fk
			     	references rhnFile(id),
        location        varchar2(128)
	    	    	constraint rhn_fileloc_loc_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_fileloc_file_loc_uq
	on rhnFileLocation(file_id, location)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
