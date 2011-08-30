-- during 05 -> 0.6 schema upgrade RHN_RCM_PVA_DEF_UNIQ had been mis-renamed
-- to RHN_RCM_PVAR_UNIQ

declare
    constraint_not_exists exception;
    pragma exception_init(constraint_not_exists, -23292);
begin
    execute immediate 'alter table RHNRELEASECHANNELMAP rename constraint RHN_RCM_PVAR_UNIQ to RHN_RCM_PVA_DEF_UNIQ';
exception
    when constraint_not_exists then
        null; -- constraint has right name
end;
/

