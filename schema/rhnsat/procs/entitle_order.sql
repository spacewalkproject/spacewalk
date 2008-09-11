-- $Id$
--
-- really needs a "dev" tag and a prod tag, not exclude all
-- EXCLUDE: all

-- this is the wrapper for entitle_order() that tom gets to call
--

create or replace procedure
entitle_order (
	order_id_in in varchar2,
	pout_return_flag out varchar2,
	pout_return_errmsg out varchar2
) is
begin
	rhn_ep.entitle_order(order_id_in, pout_return_flag, pout_return_errmsg);
end;
/
show errors

-- $Log$
-- Revision 1.6  2002/05/09 22:14:36  pjones
-- exclude all, dev code.
--
-- Revision 1.5  2002/05/09 06:52:53  gafton
-- YAHOOOOOOOOOOOOOOOO!!!!!!!!!
--
-- "make satellite" finally produces schema that loads completely into a test
-- instance.
--
-- Revision 1.4  2002/02/13 19:40:37  pjones
-- this is the wrapper tom can call
--
