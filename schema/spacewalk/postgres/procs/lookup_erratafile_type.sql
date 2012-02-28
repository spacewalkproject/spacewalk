-- oracle equivalent source sha1 c37ec2fbd380eb992f2064563a80abb3a0d8f9ce
-- retrieved from ./1241042199/53fa26df463811901487b608eecc3f77ca7783a1/schema/spacewalk/oracle/procs/lookup_erratafile_type.sql
--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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

create or replace function
lookup_erratafile_type (
        label_in in varchar
) returns numeric as
$$
declare
        erratafile_type_id numeric;
begin
        select  id
        into    erratafile_type_id
        from    rhnErrataFileType
        where   label = label_in;

	if not found then
		perform rhn_exception.raise_exception('erratafile_type_not_found');
	end if;

        return erratafile_type_id;
end;
$$ language plpgsql;
