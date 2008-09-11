--
-- $Id$
--
-- this creates the channel_name_t type

create or replace type channel_name_t as table of varchar(64)
/

-- $Log$
-- Revision 1.2  2002/05/09 22:34:53  pjones
-- argh, ; doesn't work right here
--
-- Revision 1.1  2002/05/09 22:31:42  pjones
-- make types first-class schema
--
