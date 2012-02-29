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
lookup_snapshot_invalid_reason(label_in in varchar2)
return number
is
	snapshot_invalid_reason_id number;
begin
    select id
      into snapshot_invalid_reason_id
      from rhnsnapshotinvalidreason
     where label = label_in;

    return snapshot_invalid_reason_id;
exception when no_data_found then
    rhn_exception.raise_exception('invalid_snapshot_invalid_reason');
end;
/
show errors
