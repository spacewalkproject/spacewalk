create table
rhnChannelCloned
(
	original_id		number
				constraint rhn_channelclone_fcid_nn not null
				constraint rhn_channelclone_fcid_fk
					references rhnChannel(id)
					on delete cascade,
	id		        number
				constraint rhn_channelclone_tcid_nn not null
				constraint rhn_channelclone_tcid_fk
					references rhnChannel(id)
					on delete cascade,
	created			date default(sysdate)
				constraint rhn_channelclone_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_channelclone_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_channelclone_fcid_tcid_idx
	on rhnChannelCloned ( original_id, id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnChannelCloned add constraint rhn_channelclone_fcid_tcid_uq
	unique ( original_id, id );
alter table rhnChannelCloned add constraint rhn_channelclone_id_pk
        primary key ( id );

create index rhn_channelclone_tcid_fcid_idx
	on rhnChannelCloned ( id, original_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_channelclone_mod_trig
before insert or update on rhnChannelCloned
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

