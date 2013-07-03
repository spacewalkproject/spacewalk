-- oracle equivalent source sha1 201ba63fc88e621cff44b314d4fda6253acf320b
-- functional index for rhnISSMaster

create unique index rhn_issm_only_one_default on rhnISSMaster
    (is_current_master) where is_current_master = 'Y';
