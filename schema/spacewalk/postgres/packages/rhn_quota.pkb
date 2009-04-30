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


create or replace function get_org_for_config_content (
                config_content_id_in in numeric
        ) returns numeric as
        $$
        declare
                org_id numeric;
        begin

                select  cc.org_id
                into    org_id
                from    rhnConfigChannel        cc,
                                rhnConfigFile           cf,
                                rhnConfigRevision       cr
                where   cr.config_content_id = config_content_id_in
                        and cr.config_file_id = cf.id
                        and cf.config_channel_id = cc.id;

                return org_id;
end;
$$
language plpgsql;
        

create or replace function set_org_quota_total (
                org_id_in in numeric,
                total_in in numeric
        ) returns void
        as
        $$
        declare
                available numeric;
        begin
                select  total_in + oq.bonus
                into    available
                from    rhnOrgQuota oq
                where   oq.org_id = org_id_in;

                if not found  then
                        insert into rhnOrgQuota ( org_id, total )
                                values (org_id_in, total_in);
                        return;
		end if;

                perform rhn_config.prune_org_configs(org_id_in, available);

                update          rhnOrgQuota
                        set             total = total_in
                        where   org_id = org_id_in;
        
                -- right now, we completely ignore failure in setting the total to a
                -- lower number than is subscribed, because we have no prune.  prune
                -- will be in the next version, sometime in the not too distant future,
                -- on maple street.  So if the new total is smaller than used, it'll
                -- just not get updated.  We'll be ok, but someday we'll need to prune
                -- *everybody*, so we don't want to wait too long.
                exception when others then
                        null;
end;
$$
language plpgsql;

        

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


