
drop index rhn_act_eu_aid_eid_idx;
create unique index rhn_act_eu_aid_eid_uq on rhnActionErrataUpdate (action_id, errata_id);

