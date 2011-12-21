-- oracle equivalent source sha1 c9b519752b694fa39fd8685a8b86ae05b2131f64
--
-- Copyright (c) 2008--2011 Red Hat, Inc.
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

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_config,' || setting where name = 'search_path';


	-- just a stub for now
create or replace function prune_org_configs (
		org_id_in in numeric,
		total_in in numeric
	)
returns void
as $$	
begin
end;
$$ LANGUAGE 'plpgsql';


	create or replace function insert_revision (
		revision_in in numeric,
		config_file_id_in in numeric,
		config_content_id_in in numeric,
		config_info_id_in in numeric,
		config_file_type_id_in in numeric default 1
	) returns numeric as $$
               declare
		retval numeric;
		 affected_orgs cursor is
			select cc.org_id as id from rhnConfigChannel cc,
					rhnConfigFile cf
			where cf.id = config_file_id_in
				and cf.config_channel_id = cc.id;
	begin
      
		insert into rhnConfigRevision(id, revision, config_file_id,
				config_content_id, config_info_id, config_file_type_id
			) values (
				nextval('rhn_confrevision_id_seq'), revision_in, config_file_id_in,
				config_content_id_in, config_info_id_in, config_file_type_id_in
			)
			returning id into retval;

		for org in affected_orgs loop
                        perform rhn_quota.update_org_quota(org.id);
                end loop;

		return retval;
	end$$ language 'plpgsql';

	create or replace function delete_revision (
		config_revision_id_in in numeric,
		org_id_in in numeric default -1
	) returns void as $$
	declare
		cfid numeric;
		ccid numeric;
		oid numeric;
		latest_crid numeric;
		others numeric := 0;
		snapshots cursor is
			select scr.snapshot_id as id
			from rhnSnapshot s,
					rhnSnapshotConfigRevision scr
			where scr.config_revision_id = config_revision_id_in
					and scr.snapshot_id = s.id
					and s.invalid is null;
		 other_revisions cursor (config_content_id_in numeric) is
			select 1
			from rhnConfigRevision
			where config_content_id = config_content_id_in;
	begin
                for snapshot in snapshots loop
                    update rhnSnapshot
                        set invalid = lookup_snapshot_invalid_reason('cr_removed')
                        where id = snapshot.id;
                end loop;

		if org_id_in < 0 then
			select cr.config_content_id, cc.org_id
			into ccid, oid
			from rhnConfigChannel cc,
					rhnConfigFile cf,
					rhnConfigRevision cr
			where cr.id = config_revision_id_in
				and cr.config_file_id = cf.id
				and cf.config_channel_id = cc.id;
		else
			select	cr.config_content_id, org_id_in
			into	ccid, oid
			from	rhnConfigRevision cr
			where	cr.id = config_revision_id_in;
		end if;

		-- right now this will set rhnActionConfigFileName.config_revision_id
		-- to null, and will remove an entry from rhnActionConfigRevision.
		-- might we want to prune and/or kill the action in some way?  maybe
		-- mark it failed or something?
		delete from rhnConfigRevision where id = config_revision_id_in;

		-- now prune away content if there aren't any other revisions pointing
		-- at it
		for other_revision in other_revisions(ccid) loop
			others := 1;
			exit;
		end loop;
		if others = 0 then
			delete from rhnConfigContent where id = ccid;
		end if;

		-- now make sure rhnConfigFile points at a valid revision;
		-- if there isn't one, we're deleting it, _unless_ org_id_in is
		-- >= 0, in which case we're in the delete trigger anyway
		if org_id_in < 0 then
			select	cf.latest_config_revision_id,
					cf.id
			into latest_crid,
					cfid
			from rhnConfigFile cf,
					rhnConfigRevision cr
			where cr.id = config_revision_id_in
				and cr.config_file_id = cf.id;

			if latest_crid = config_revision_id_in then
				latest_crid := rhn_config.get_latest_revision(cfid);
				if latest_crid is not null then
					update rhnConfigFile set latest_config_revision_id = latest_crid
						where id = cfid;
				else
					delete from rhnConfigFile where id = cfid;
				end if;
			end if;

		end if;
		perform rhn_quota.update_org_quota(oid);

	end ;
$$ LANGUAGE 'plpgsql';

	create or replace function get_latest_revision (
		config_file_id_in in numeric
		) 
		returns numeric as $$
		declare 
 		revision1 record;
		begin
		for revision1 in 
			select cr.id 
			from rhnConfigRevision cr
			where cr.config_file_id = config_file_id_in
			order by revision desc
		loop
			return revision1.id;
		end loop;
		return null;
end;
$$ LANGUAGE 'plpgsql';

	create or replace function insert_file (
		config_channel_id_in in numeric,
		name_in in varchar
	) returns numeric as $$
		declare
		retval numeric;
	begin
		select nextval('rhn_conffile_id_seq')
		into retval;

		insert into rhnConfigFile(id, config_channel_id, config_file_name_id, 
				state_id
			) (
				select retval,
						config_channel_id_in,
						lookup_config_filename(name_in),
						id
				from rhnConfigFileState
				where label = 'alive'
			);

		return retval;
	end;
$$ LANGUAGE 'plpgsql';

	create or replace function delete_file (
		config_file_id_in in numeric
	) returns void as $$
declare
org_id numeric;
revision record;
			
	begin
		for revision in 
		select cr.id, cc.org_id
			from rhnConfigChannel cc,
					rhnConfigRevision cr,
					rhnConfigFile cf
			where cf.id = config_file_id_in
				and cf.config_channel_id = cc.id
				and cr.config_file_id = cf.id
		
                loop
			perform rhn_config.delete_revision(revision.id, revision.org_id);
			org_id := revision.org_id;
		end loop;
		perform rhn_quota.update_org_quota(org_id);
		delete from rhnConfigFile where id = config_file_id_in;
	end;
$$ LANGUAGE 'plpgsql';

	create or replace function insert_channel (
		org_id_in in numeric,
		type_in in varchar,
		name_in in varchar,
		label_in in varchar,
		description_in in varchar
	) returns numeric as $$
declare
		retval numeric;
	begin
		select nextval ('rhn_confchan_id_seq')
		into retval;

		insert into rhnConfigChannel(id, org_id, confchan_type_id,
				name, label, description
			) (
				select	retval,
						org_id_in,
						cct.id,
						name_in,
						label_in,
						description_in
				from rhnConfigChannelType cct
				where label = type_in
			);
		return retval;
	end;
$$ LANGUAGE 'plpgsql';

	create or replace function delete_channel (
		config_channel_id_in in numeric
	) returns void as $$
declare
	config_file record;		
	begin
		for config_file in 
		select id
			from rhnConfigFile
			where config_channel_id = config_channel_id_in
                loop
                    perform rhn_config.delete_file(config_file.id);
		end loop;
		delete from rhnConfigChannel where id = config_channel_id_in;

end;
$$ LANGUAGE 'plpgsql';

update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_config')+1) ) where name = 'search_path';
