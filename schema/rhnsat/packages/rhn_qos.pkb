-- 
-- $Id$
-- EXCLUDE: all
--
-- query entitlement information for quality of service

create or replace package body rhn_qos is
	function slot_count(org_id_in in number, label_in in varchar2) return number is
		tally		number;
	begin
		select	max_members
		into	tally
		from	rhnServerGroupType	rsgt,
				rhnServerGroup		rsg
		where	1=1
				and rsgt.label = label_in
				and rsgt.id = rsg.group_type
				and rsg.org_id = org_id_in;
		return tally;
	exception
		when no_data_found then
			return 0;
	end slot_count;

	function basic_slot_count(org_id_in in number) return number is
	begin
		return slot_count(org_id_in, 'sw_mgr_entitled');
	end basic_slot_count;

	function workgroup_slot_count(org_id_in in number) return number is
	begin
		return slot_count(org_id_in, 'enterprise_entitled');
	end workgroup_slot_count;

	function channel_slot_count(org_id_in in number, label_in in number) return number is
		tally		number;
	begin
		select	max_members
		into	tally
		from	rhnChannelFamily			rcf,
				rhnOrgChannelFamilyPermissions rcfp
		where	1=1
				and rcf.label = label_in
				and rcf.id = rcfp.channel_family_id
				and rcfp.org_id = org_id_in;
		return tally;
	exception
		when no_data_found then
			return 0;
	end channel_slot_count;
				
	function as_slot_count(org_id_in in number) return number is
	begin
		return channel_slot_count(org_id_in, 'rh-advanced-server');
	end as_slot_count;

end rhn_qos;
/
show errors

-- $Log$
-- Revision 1.2  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
-- Revision 1.1  2002/10/02 18:44:23  pjones
-- qos stuff
--
