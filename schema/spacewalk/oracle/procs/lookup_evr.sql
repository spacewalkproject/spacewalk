-- Copyright (c) 2008-2012 Red Hat, Inc.
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

create or replace function
lookup_evr(e_in in varchar2, v_in in varchar2, r_in in varchar2)
return number
is
    evr_id  number;
begin
    select id
      into evr_id
      from rhnPackageEVR
    where ((epoch is null and e_in is null) or (epoch = e_in)) and
          version = v_in and
          release = r_in;
	  
    return evr_id;
exception when no_data_found then
    begin
        evr_id := insert_evr(e_in, v_in, r_in);
    exception when dup_val_on_index then
        select id
          into evr_id
          from rhnPackageEVR
        where ((epoch is null and e_in is null) or (epoch = e_in)) and
              version = v_in and
              release = r_in;
    end;

	return evr_id;
end;
/
show errors
