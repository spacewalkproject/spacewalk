-- created by Oraschemadoc Mon Aug 31 10:54:43 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PACKAGE "MIM1"."RHN_QUOTA" 
is
	function recompute_org_quota_used (
		org_id_in in number
	) return number;

	function get_org_for_config_content (
		config_content_id_in in number
	) return number;

	procedure set_org_quota_total (
		org_id_in in number,
		total_in in number
	);

	procedure update_org_quota (
		org_id_in in number
	);
end rhn_quota;
CREATE OR REPLACE PACKAGE BODY "MIM1"."RHN_QUOTA" 
is
	function recompute_org_quota_used (
		org_id_in in number
	) return number is
		retval number := 0;
	begin
		begin
			select	NVL(sum(a.file_size),0)
			into	retval
			from	(
				select	distinct content.id, content.file_size
				from	rhnConfigContent	content,
						rhnConfigRevision	cr,
						rhnConfigFile		cf,
						rhnConfigChannel	cc
				where	cc.org_id = org_id_in
					and cc.id = cf.config_channel_id
					and cf.id = cr.config_file_id
					and cr.config_content_id = content.id
				) a;
		exception
			when others then
				null;
		end;

		return retval;
	end recompute_org_quota_used;

	function get_org_for_config_content (
		config_content_id_in in number
	) return number is
		org_id number;
	begin

		select	cc.org_id
		into	org_id
		from	rhnConfigChannel	cc,
				rhnConfigFile		cf,
				rhnConfigRevision	cr
		where	cr.config_content_id = config_content_id_in
			and cr.config_file_id = cf.id
			and cf.config_channel_id = cc.id;

		return org_id;
	end get_org_for_config_content;

	procedure set_org_quota_total (
		org_id_in in number,
		total_in in number
	) is
		available number;
	begin
		select	total_in + oq.bonus
		into	available
		from	rhnOrgQuota oq
		where	oq.org_id = org_id_in;

		rhn_config.prune_org_configs(org_id_in, available);

		update		rhnOrgQuota
			set		total = total_in
			where	org_id = org_id_in;
	exception
		when no_data_found then
			insert into rhnOrgQuota ( org_id, total )
				values (org_id_in, total_in);
		-- right now, we completely ignore failure in setting the total to a
		-- lower number than is subscribed, because we have no prune.  prune
		-- will be in the next version, sometime in the not too distant future,
		-- on maple street.  So if the new total is smaller than used, it'll
		-- just not get updated.  We'll be ok, but someday we'll need to prune
		-- *everybody*, so we don't want to wait too long.
		when others then
			null;
	end set_org_quota_total;

	procedure update_org_quota (
		org_id_in in number
	) is
	begin
		update rhnOrgQuota
			set used = rhn_quota.recompute_org_quota_used(org_id_in)
			where org_id = org_id_in;
	end update_org_quota;
end rhn_quota;
 
/
