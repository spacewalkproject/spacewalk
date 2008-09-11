--
-- $Id$
--
-- granularity for monitor data
--

create table
rhnMonitorGranularity
(
	id		number
			constraint rhn_monitorgran_id_nn not null
			constraint rhn_monitorgran_id_pk primary key
				using index tablespace [[4m_tbs]],
	label		varchar2(16)
			constraint rhn_monitorgran_label_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_monitorgranularity_id_seq;

create unique index rhn_monitorgran_label_uq
	on rhnMonitorGranularity(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- last created gets used in Rule, make it the most useful index.
create index rhn_monitorgran_label_id_idx
	on rhnMonitorGranularity(label,id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.3  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.2  2002/08/08 19:09:55  pjones
-- shortened some identifiers
--
-- Revision 1.1  2002/08/07 18:12:42  pjones
-- add commit to rhnUserMessageStatus_data, check in everything else.
--
