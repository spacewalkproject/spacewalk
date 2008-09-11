--
-- $Id$
-- EXCLUDE: all
--

create sequence rhn_hwpropname_id_seq;

create table
rhnHardwarePropName
(
	id			number
				constraint rhn_hwpropname_id_nn not null,
	name			varchar2(20)
				constraint rhn_hwpropname_name_nn not null
)
	storage ( freelists 16 ) -- this is probably a waste
	initrans 32		 -- so is this, same below
/

create index rhn_hwpropname_id_idx
	on rhnHardwarePropName ( id ) 
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnHardwarePropName add constraint rhn_hwpropname_id_pk
	primary key ( id );

create index rhn_hwpropname_name_id_idx
	on rhnHardwarePropName ( name, id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnHardwarePropName add constraint rhn_hwpropname_name_uq
	unique ( name );

-- $Log$
-- Revision 1.5  2003/08/20 16:36:07  pjones
-- bugzilla: none
--
-- disable rhnHardware
--
-- Revision 1.4  2003/06/20 15:35:56  pjones
-- bugzilla: 84125
-- change sequence start point
-- fix create table syntax
--
-- Revision 1.3  2003/06/19 22:08:46  pjones
-- bugzilla: 84125
--
-- New hardware schema.  This looks pretty final, but conversion is still
-- a work in progress.
--
-- Revision 1.2  2003/03/05 00:05:38  pjones
-- make it a bit faster, mostly
--
-- Revision 1.1  2003/02/27 00:35:12  pjones
-- new hardware tables
-- lookup functions and conversion scripts to come tomorrow
-- Also todo: makefile.deps
--
