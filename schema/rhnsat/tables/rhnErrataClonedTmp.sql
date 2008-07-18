create table
rhnErrataClonedTmp
(
	original_id		number
				constraint rhn_eclonedtmp_feid_nn not null
				constraint rhn_eclonedtmp_feid_fk
					references rhnErrata(id)
					on delete cascade,
	id		                                                                number
				constraint rhn_eclonedtmp_teid_nn not null
				constraint rhn_eclonedtmp_teid_fk
					references rhnErrataTmp(id)
					on delete cascade,
	created			date default(sysdate)
				constraint rhn_eclonedtmp_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_eclonedtmp_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_eclonedtmp_feid_teid_idx
	on rhnErrataClonedTmp ( original_id, id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnErrataClonedTmp add constraint rhn_eclonedtmp_feid_teid_uq
	unique ( original_id, id );
alter table rhnErrataClonedTmp add constraint rhn_eclonedtmp_id_pk
        primary key ( id );

create index rhn_eclonedtmp_teid_feid_idx
	on rhnErrataClonedTmp ( id, original_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_eclonedtmp_mod_trig
before insert or update on rhnErrataClonedTmp
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

