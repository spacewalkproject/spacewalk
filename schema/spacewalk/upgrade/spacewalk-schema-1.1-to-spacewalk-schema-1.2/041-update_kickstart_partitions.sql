declare
  lob_data blob;

  function gen_part_line(cname in varchar2, arg in varchar2)
  return varchar2
  is
      ret varchar2(4000);
  begin
      ret := case cname
                  when 'partitions' then 'part'
                  when 'raids' then 'raid'
                  when 'volgroups' then 'volgroup'
                  when 'logvols' then 'logvol'
                  when 'include' then '%include'
                  when 'custom_partition' then NULL
             end;
      if arg like 'swap%'
         and arg not like 'swap %'
         and arg not like 'swap.%' then
          ret := ret || ' swap' || substr(arg, instr(arg,' '));
      else
          ret := ret || ' ' || arg;
      end if;
      return trim(ret);
  end gen_part_line;

begin
    for kickstart in (
        select distinct kc.kickstart_id
          from rhnKickstartCommand kc
         inner join rhnKickstartCommandName kcn
            on kcn.id = kc.ks_command_name_id
         where kcn.name in ('partitions', 'raids', 'volgroups', 'logvols', 'include', 'custom_partition')
         order by kc.kickstart_id
    ) loop

        update rhnKSData
           set partition_data = empty_blob()
         where id = kickstart.kickstart_id
        returning partition_data into lob_data;

        for command in (
                select kcn.name, kc.arguments
                  from rhnKickstartCommand kc
                 inner join rhnKickstartCommandName kcn
                    on kcn.id = kc.ks_command_name_id
                 where kcn.name in ('partitions', 'raids', 'volgroups', 'logvols', 'include', 'custom_partition')
                   and kc.kickstart_id = kickstart.kickstart_id
                 order by kcn.sort_order, kc.arguments
        ) loop
           if length(lob_data) > 0 then
               dbms_lob.append(lob_data, utl_raw.cast_to_raw(chr(10)));
           end if;
           dbms_lob.append(lob_data, utl_raw.cast_to_raw(gen_part_line(command.name, command.arguments)));
        end loop;

    end loop;

    delete from rhnKickstartCommand
     where ks_command_name_id in (
                select id
                  from rhnKickstartCommandName
                 where name in ('partitions','raids', 'volgroups','logvols','include','custom_partition'));

    delete from rhnKickstartCommandName
     where name in ('partitions', 'raids', 'volgroups', 'logvols', 'include', 'custom_partition');

end;
/
