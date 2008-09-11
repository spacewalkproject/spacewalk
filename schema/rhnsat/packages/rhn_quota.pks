--
-- $Id$
--

create or replace package
rhn_quota
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
/
show errors

--
-- $Log$
-- Revision 1.2  2004/01/07 20:52:36  pjones
-- bugzilla: 113029 -- helper function to do updates of used quota total
--
-- Revision 1.1  2003/12/19 22:07:30  pjones
-- bugzilla: 112392 -- quota support for config files
--
