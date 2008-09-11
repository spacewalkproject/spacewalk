--
-- $Id$
--

create or replace synonym rhn_date_manip for rhn.rhn_date_manip;

-- $Log$
-- Revision 1.2  2004/01/28 22:22:10  pjones
-- bugzilla: none -- one of the dumbest typos ever, now fixed.  We never
-- refer to this package from rhnuser, so I don't think it makes any
-- significant difference...
--
-- Revision 1.1  2003/03/07 23:13:58  pjones
-- date manipulation procedures
-- so far, these pick date ranges to do reports from
--
