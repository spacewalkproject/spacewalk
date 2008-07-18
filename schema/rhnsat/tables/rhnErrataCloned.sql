create table
rhnErrataCloned
(
	original_id		number
				constraint rhn_errataclone_feid_nn not null
				constraint rhn_errataclone_feid_fk
					references rhnErrata(id)
					on delete cascade,
	id		        number
				constraint rhn_errataclone_teid_nn not null
				constraint rhn_errataclone_teid_fk
					references rhnErrata(id)
					on delete cascade,
	created			date default(sysdate)
				constraint rhn_errataclone_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_errataclone_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_errataclone_feid_teid_idx
	on rhnErrataCloned ( original_id, id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnErrataCloned add constraint rhn_errataclone_feid_teid_uq
	unique ( original_id, id );
alter table rhnErrataCloned add constraint rhn_errataclone_id_pk
        primary key ( id );

create index rhn_errataclone_teid_feid_idx
	on rhnErrataCloned ( id, original_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_errataclone_mod_trig
before insert or update on rhnErrataCloned
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

