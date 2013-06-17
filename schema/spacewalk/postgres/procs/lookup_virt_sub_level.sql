-- oracle equivalent source sha1 e503fcd49af7798be7ac27d4d1ea514d2b343a05
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/procs/lookup_virt_sub_level.sql
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
--
--

create or replace function
lookup_virt_sub_level(label_in in varchar)
returns numeric
as
$$
declare
        virt_sub_level_id numeric;
begin
        select  vsl.id
        into    virt_sub_level_id
        from    rhnVirtSubLevel vsl
        where   vsl.label = label_in;

        if not found then
		perform rhn_exception.raise_exception('invalid_virt_sub_level');
        end if;

        return virt_sub_level_id;

end;
$$ language plpgsql stable;
