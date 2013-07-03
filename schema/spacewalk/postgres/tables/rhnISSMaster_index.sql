-- functional index for rhnISSMaster

create unique index rhn_issm_only_one_default on rhnISSMaster
    (is_current_master) where is_current_master = 'Y';
