-- functional index for rhnISSMaster

create unique index rhn_issm_only_one_default on rhnISSMaster (
	case when is_current_master = 'Y' then is_current_master end);
