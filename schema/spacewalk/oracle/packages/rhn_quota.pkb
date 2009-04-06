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
--
--

create or replace package body
rhn_quota
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
show errors

--
--
-- Revision 1.5  2004/01/15 20:15:02  pjones
-- bugzilla: none -- you can't delete the last server in an org, because sum()
-- will give null and you'll fail to update the used quota.
--
-- Revision 1.4  2004/01/09 16:23:41  pjones
-- bugzilla: none -- fix a silly comment ;)
--
-- Revision 1.3  2004/01/07 20:52:36  pjones
-- bugzilla: 113029 -- helper function to do updates of used quota total
--
-- Revision 1.2  2004/01/05 20:35:41  pjones
-- bugzilla: 112553 -- fix the insert case for quota
--
-- Revision 1.1  2003/12/19 22:07:30  pjones
-- bugzilla: 112392 -- quota support for config files
--
