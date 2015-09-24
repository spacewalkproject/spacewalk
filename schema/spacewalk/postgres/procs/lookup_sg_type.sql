-- oracle equivalent source sha1 655dc5315296c94bb0307198c381cd417705e41c
-- retrieved from ./1235730481/28a92ec2f6056ccc56e0bc4b0da3630def22548f/schema/spacewalk/rhnsat/procs/lookup_sg_type.sql
--
-- Copyright (c) 2008--2015 Red Hat, Inc.
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


create or replace function
lookup_sg_type(label_in in varchar)
returns numeric
as
$$
declare
        server_group_type_id numeric;
begin
        select  id
        into    server_group_type_id
        from    rhnServerGroupType sgt
        where   label = label_in;

        if not found then
		perform rhn_exception.raise_exception('invalid_server_group');
        end if;

        return server_group_type_id;
          
end;
$$ language plpgsql;


