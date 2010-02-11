-- created by Oraschemadoc Fri Jan 22 13:41:06 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PACKAGE "SPACEWALK"."RHN_CONFIG"
is
	procedure prune_org_configs (
		org_id_in in number,
		total_in in number
	);

	function insert_revision (
		revision_in in number,
		config_file_id_in in number,
		config_content_id_in in number,
		config_info_id_in in number,
		delim_start_in in varchar2 := '{@',
		delim_end_in in varchar2 := '@}',
      config_file_type_id_in number := 1
	) return number;

	procedure delete_revision (
		config_revision_id_in in number,
		org_id_in in number := -1
	);

	function get_latest_revision (
		config_file_id_in in number
	) return number;

	function insert_file (
		config_channel_id_in in number,
		name_in in varchar2
	) return number;

	procedure delete_file (
		config_file_id_in in number
	);

	function insert_channel (
		org_id_in in number,
		type_in in varchar2,
		name_in in varchar2,
		label_in in varchar2,
		description_in in varchar2
	) return number;

	procedure delete_channel (
		config_channel_id_in in number
	);
end rhn_config;
CREATE OR REPLACE PACKAGE BODY "SPACEWALK"."RHN_CONFIG"
is
	-- just a stub for now
	procedure prune_org_configs (
		org_id_in in number,
		total_in in number
	) is
	begin
		null;
	end prune_org_configs;

	function insert_revision (
		revision_in in number,
		config_file_id_in in number,
		config_content_id_in in number,
		config_info_id_in in number,
		delim_start_in in varchar2 := '{@',
		delim_end_in in varchar2 := '@}',
      config_file_type_id_in in number := 1
	) return number is
		retval number;
		cursor affected_orgs is
			select	cc.org_id id
			from	rhnConfigChannel cc,
					rhnConfigFile cf
			where	cf.id = config_file_id_in
				and cf.config_channel_id = cc.id;
	begin

		insert into rhnConfigRevision(id, revision, config_file_id,
				config_content_id, config_info_id, delim_start, delim_end,
            config_file_type_id
			) values (
				rhn_confrevision_id_seq.nextval, revision_in, config_file_id_in,
				config_content_id_in, config_info_id_in, delim_start_in,
				delim_end_in, config_file_type_id_in
			)
			returning id into retval;

		for org in affected_orgs loop
			rhn_quota.update_org_quota(org.id);
		end loop;

		return retval;
	end insert_revision;

	procedure delete_revision (
		config_revision_id_in in number,
		org_id_in in number := -1
	) is
		cfid number;
		ccid number;
		oid number;
		latest_crid number;
		others number := 0;
		cursor snapshots is
			select	scr.snapshot_id id
			from	rhnSnapshot s,
					rhnSnapshotConfigRevision scr
			where	scr.config_revision_id = config_revision_id_in
					and scr.snapshot_id = s.id
					and s.invalid is null;
		cursor other_revisions(config_content_id_in in number) is
			select	1
			from	rhnConfigRevision
			where	config_content_id = config_content_id_in;
	begin
		for snapshot in snapshots loop
			update		rhnSnapshot s
				set		s.invalid =
							lookup_snapshot_invalid_reason('cr_removed')
				where	s.id = snapshot.id;
		end loop;

		if org_id_in < 0 then
			select	cr.config_content_id, cc.org_id
			into	ccid, oid
			from	rhnConfigChannel cc,
					rhnConfigFile cf,
					rhnConfigRevision cr
			where	cr.id = config_revision_id_in
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
			into	latest_crid,
					cfid
			from	rhnConfigFile cf,
					rhnConfigRevision cr
			where	cr.id = config_revision_id_in
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
		rhn_quota.update_org_quota(oid);
	end delete_revision;

	function get_latest_revision (
		config_file_id_in in number
	) return number is
		cursor revisions is
			select	cr.id
			from	rhnConfigRevision cr
			where	cr.config_file_id = config_file_id_in
			order by revision desc;
	begin
		for revision in revisions loop
			return revision.id;
		end loop;
		return null;
	end get_latest_revision;

	function insert_file (
		config_channel_id_in in number,
		name_in in varchar2
	) return number is
		retval number;
	begin
		select	rhn_conffile_id_seq.nextval
		into	retval
		from	dual;

		insert into rhnConfigFile(id, config_channel_id, config_file_name_id,
				state_id
			) (
				select	retval,
						config_channel_id_in,
						lookup_config_filename(name_in),
						id
				from	rhnConfigFileState
				where	label = 'alive'
			);

		return retval;
	end insert_file;

	procedure delete_file (
		config_file_id_in in number
	) is
		cursor revisions is
			select	cr.id, cc.org_id
			from	rhnConfigChannel cc,
					rhnConfigRevision cr,
					rhnConfigFile cf
			where	cf.id = config_file_id_in
				and cf.config_channel_id = cc.id
				and cr.config_file_id = cf.id;
		org_id number;
	begin
		for revision in revisions loop
			rhn_config.delete_revision(revision.id, revision.org_id);
			org_id := revision.org_id;
		end loop;
		rhn_quota.update_org_quota(org_id);
		delete from rhnConfigFile where id = config_file_id_in;
	end delete_file;

	function insert_channel (
		org_id_in in number,
		type_in in varchar2,
		name_in in varchar2,
		label_in in varchar2,
		description_in in varchar2
	) return number is
		retval number;
	begin
		select	rhn_confchan_id_seq.nextval
		into	retval
		from	dual;

		insert into rhnConfigChannel(id, org_id, confchan_type_id,
				name, label, description
			) (
				select	retval,
						org_id_in,
						cct.id,
						name_in,
						label_in,
						description_in
				from	rhnConfigChannelType cct
				where	label = type_in
			);
		return retval;
	end insert_channel;

	procedure delete_channel (
		config_channel_id_in in number
	) is
		cursor config_files is
			select	id
			from	rhnConfigFile
			where	config_channel_id = config_channel_id_in;
	begin
		for config_file in config_files loop
			rhn_config.delete_file(config_file.id);
		end loop;
		delete from rhnConfigChannel where id = config_channel_id_in;
	end delete_channel;
end rhn_config;
 
/
