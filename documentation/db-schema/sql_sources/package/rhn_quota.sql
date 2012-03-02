-- created by Oraschemadoc Fri Mar  2 05:58:14 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PACKAGE "SPACEWALK"."RHN_QUOTA" 
is
	function recompute_org_quota_used (
		org_id_in in number
	) return number;

	procedure update_org_quota (
		org_id_in in number
	);
end rhn_quota;
CREATE OR REPLACE PACKAGE BODY "SPACEWALK"."RHN_QUOTA" 
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
