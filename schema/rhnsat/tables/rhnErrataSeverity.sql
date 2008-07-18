--
-- $Id: $
--

create table rhnErrataSeverity (
    id number
        constraint rhn_errata_sev_id_nn not null 
        constraint rhn_errata_sev_id_pk primary key,
    rank number 
        constraint rhn_errata_sev_rank_nn not null,
    label varchar2(40)
        constraint rhn_errata_sev_label_nn not null
)
	enable row movement
;

