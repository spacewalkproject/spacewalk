-- oracle equivalent source sha1 4fb3a3e657d9f0440d4429b833e0bc5b2eb18b94
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

--create schema rhn_quota;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_quota,' || setting where name = 'search_path';

create or replace function recompute_org_quota_used (
                org_id_in in numeric
        ) returns numeric as
        $$
        declare
                retval numeric;
        begin
                        select  COALESCE(sum(a.file_size),0)
                        into    retval
                        from    (
                                select  distinct content.id, content.file_size
                                from    rhnConfigContent        content,
                                                rhnConfigRevision       cr,
                                                rhnConfigFile           cf,
                                                rhnConfigChannel        cc
                                where   cc.org_id = org_id_in
                                        and cc.id = cf.config_channel_id
                                        and cf.id = cr.config_file_id
                                        and cr.config_content_id = content.id
                                ) a;

                return retval;
end;
$$ language plpgsql;


create or replace function update_org_quota (
                org_id_in in numeric
        ) returns void
        as
        $$
        begin
                update rhnOrgQuota
                        set used = rhn_quota.recompute_org_quota_used(org_id_in)
                        where org_id = org_id_in;

end;
$$
language plpgsql;



-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_quota')+1) ) where name = 'search_path';


