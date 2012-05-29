
alter trigger rhn_privcf_mod_trig disable;
alter table rhnPrivateChannelFamily add FVE_MAX_MEMBERS NUMBER default (0);
alter table rhnPrivateChannelFamily add FVE_CURRENT_MEMBERS NUMBER
        DEFAULT (0) NOT NULL;
alter trigger rhn_privcf_mod_trig enable;
