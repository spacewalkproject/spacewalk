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

