--
-- $Id$
-- EXCLUDE: all

create table
rhnHardwareProperties
(
	hardware_id		number
				constraint rhn_hwprop_hid_nn not null
				constraint rhn_hwprop_hid_fk
					references rhnHardware(id),
	name_id			number
				constraint rhn_hwprop_nid_nn not null
				constraint rhn_hwprop_nid_fk
					references rhnHardwarePropName(id),
	value_id		number
				constraint rhn_hwprop_vid_nn not null
				constraint rhn_hwprop_vid_fk
					references rhnHardwarePropValue(id)
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_hwprop_hid_nid_vid_idx
	on rhnHardwareProperties ( hardware_id, name_id, value_id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.3  2003/08/20 16:36:07  pjones
-- bugzilla: none
--
-- disable rhnHardware
--
-- Revision 1.2  2003/06/19 22:08:46  pjones
-- bugzilla: 84125
--
-- New hardware schema.  This looks pretty final, but conversion is still
-- a work in progress.
--
-- Revision 1.1  2003/02/27 00:35:12  pjones
-- new hardware tables
-- lookup functions and conversion scripts to come tomorrow
-- Also todo: makefile.deps
--
