-- select data about tests with truncated identifiers into temp table
create table tmp_oscap_upgrade as
        select row_number() over (partition by testresult_id order by rr.id) as rn,
               rr.id, rr.testresult_id, rr.result_id,
               xi.id as ident_id,
               0 as new_ident_id
          from rhnXccdfRuleresult rr
          join rhnXccdfRuleIdentmap rim
            on rim.rresult_id=rr.id
          join rhnxccdfident xi
            on xi.id = rim.ident_id
         where xi.identifier like '%...';

-- create new ids to truncated identifiers
create table tmp_oscap_upgrade_ids as
        select rn, ident_id, sequence_nextval('rhn_xccdf_ident_id_seq') as new_id
          from (select distinct rn, ident_id from tmp_oscap_upgrade) X;
 
-- assign new ids to selected identifiers
update tmp_oscap_upgrade u set new_ident_id = (select new_id from tmp_oscap_upgrade_ids i 
                                                where i.rn = u.rn and i.ident_id = u.ident_id);

-- create new (separated) test identifiers
insert into rhnxccdfident (id, identsystem_id, identifier)
        select distinct u.new_ident_id, o.identsystem_id, o.identifier || u.rn
          from tmp_oscap_upgrade u
          join rhnxccdfident o on u.ident_id = o.id
         where o.identifier like '%...';

-- create new rule maps
insert into rhnXccdfRuleIdentmap (rresult_id, ident_id)
        select id, new_ident_id from tmp_oscap_upgrade;

-- delete old rule maps
delete from rhnXccdfRuleIdentmap where ident_id in
        (select ident_id from tmp_oscap_upgrade);

-- remove temporary tables
drop table tmp_oscap_upgrade_ids;
drop table tmp_oscap_upgrade;
