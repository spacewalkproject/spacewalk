
create table
rhnContentSourceFilter
(
        id		number NOT NULL
			constraint rhn_csf_id_pk primary key,
        source_id		number
			constraint rhn_csf_source_fk
                                references rhnContentSource (id),
        sort_order	number NOT NULL,
        flag            varchar2(1) NOT NULL
                        check (flag in ('+','-')),
        filter          varchar2(4000) NOT NULL,
        created         date default(sysdate) NOT NULL,
        modified        date default(sysdate) NOT NULL
)
	enable row movement
  ;


create sequence rhn_csf_id_seq start with 500;

CREATE UNIQUE INDEX rhn_csf_sid_so_uq
    ON rhnContentSourceFilter (source_id, sort_order)
    tablespace [[64k_tbs]];

