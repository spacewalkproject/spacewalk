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

-- create schema rhn_qos;

--update in pg_setting
update pg_settings set setting = 'rhn_qos,' || setting where name = 'search_path';

create or replace function slot_count
                       (org_id_in in numeric,
                       label_in in varchar)
   returns numeric as $$
    Declare                 
 tally           numeric;
        begin
                select  max_members
                into    tally
                from    rhnServerGroupType      rsgt,
                                rhnServerGroup          rsg
                where   1=1
                                and rsgt.label = label_in
                                and rsgt.id = rsg.group_type
                                and rsg.org_id = org_id_in;
       
                 if not found then
                         return 0;
                 end if;
                        return tally;
       
        end ;
$$ language plpgsql;


Create or replace function basic_slot_count(org_id_in in numeric)
 returns numeric as $$
        begin
                return slot_count(org_id_in, 'sw_mgr_entitled');
        end ;
      $$ language plpgsql;



Create or replace function workgroup_slot_count(org_id_in in numeric) 
 returns numeric as $$
        begin
                return slot_count(org_id_in, 'enterprise_entitled');
        end;
        $$ language plpgsql;


 create or replace function channel_slot_count(org_id_in in numeric, label_in in numeric) 
  returns numeric as $$
            declare
                tally           numeric;
        begin
                select  max_members
                into    tally
                from    rhnChannelFamily        rcf,
                                rhnOrgChannelFamilyPermissions rcfp
                where   1=1
                                and rcf.label = label_in
                                and rcf.id = rcfp.channel_family_id
                                and rcfp.org_id = org_id_in;
                
       if not found then
                         return 0;
                 end if;
        return tally;
        end;
        $$ language plpgsql;

Create or replace function as_slot_count(org_id_in in numeric)
  returns numeric as $$
        begin
                return channel_slot_count(org_id_in, 'rh-advanced-server');
        end ;
         $$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_qos')+1) ) where name = 'search_path';

