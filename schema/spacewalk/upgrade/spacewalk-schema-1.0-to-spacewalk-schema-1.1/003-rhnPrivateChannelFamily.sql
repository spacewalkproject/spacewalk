alter table rhnPrivateChannelFamily add max_flex NUMBER;
alter table rhnPrivateChannelFamily add current_flex NUMBER
        DEFAULT (0) NOT NULL;
