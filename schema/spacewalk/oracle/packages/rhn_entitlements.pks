--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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
--
--
--

create or replace
package rhn_entitlements
is
	body_version varchar2(100) := '';

   type ents_array is varray(10) of rhnServerGroupType.label%TYPE;

   function entitlement_grants_service (
	    entitlement_in in varchar2,
		service_level_in in varchar2
	) return number;

   function can_entitle_server (
      server_id_in   in number,
      type_label_in  in varchar2
   )
   return number;

   function can_switch_base (
      server_id_in   in    integer,
      type_label_in  in    varchar2
   )
   return number;

	procedure entitle_server (
		server_id_in in number,
		type_label_in in varchar2
	);

	procedure remove_server_entitlement (
		server_id_in in number,
		type_label_in in varchar2
	);

	procedure unentitle_server (
		server_id_in in number
	);

	function get_server_entitlement (
		server_id_in in number
	) return ents_array;

end rhn_entitlements;
/
show errors

