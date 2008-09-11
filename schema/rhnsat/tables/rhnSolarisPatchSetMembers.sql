
-- $Id$
create table rhnSolarisPatchSetMembers (
   patch_id          number
                     constraint rhn_solaris_psm_pid_nn not null
                     constraint rhn_solaris_psm_pid_fk references rhnPackage(id)
                     on delete cascade,
   patch_set_id      number
                     constraint rhn_solaris_psm_psid_nn not null
                     constraint rhn_solaris_psm_psid_fk references rhnPackage(id)
                     on delete cascade,
   patch_order       number,
   created           date default(sysdate)
                     constraint rhn_solaris_psm_created_nn not null,
   modified          date default(sysdate)
                     constraint rhn_solaris_psm_modified_nn not null
)
tablespace [[8m_data_tbs]]
storage( pctincrease 1 freelists 16 )
initrans 32;

create index rhn_solaris_psm_pid_psid_idx
on rhnSolarisPatchSetMembers (patch_id, patch_set_id)
tablespace [[4m_tbs]]
storage ( freelists 16 )
initrans 32;

create index rhn_solaris_psm_psid_pid_idx
on rhnSolarisPatchSetMembers (patch_set_id, patch_id)
tablespace [[4m_tbs]]
storage ( freelists 16 )
initrans 32;

create trigger
rhn_solaris_psm_mod_trig
before update on rhnSolarisPatchSetMembers
for each row
begin
   :new.modified := sysdate;
end;
/
show errors;

-- $Log$
