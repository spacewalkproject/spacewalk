--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
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
