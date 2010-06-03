alter table rhnPrivateChannelFamily add FVE_MAX_MEMBERS NUMBER default (0);
alter table rhnPrivateChannelFamily add FVE_CURRENT_MEMBERS NUMBER
        DEFAULT (0) NOT NULL;
