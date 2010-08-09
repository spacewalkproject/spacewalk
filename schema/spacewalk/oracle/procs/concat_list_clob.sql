
create or replace function concat_list_clob(
        concat_string in varchar,
        cur in sys_refcursor,
        close_the_cursor in integer default 0
)
return clob
is
    ret clob;
    tmp varchar2(4000);
begin
    dbms_lob.createtemporary(ret, true); 
    loop
        fetch cur into tmp;
        exit when cur%notfound;
        if cur%rowcount > 1 then
            dbms_lob.writeappend(ret, length(concat_string), concat_string);
        end if;
        dbms_lob.writeappend(ret, length(tmp), tmp);
    end loop;
    if close_the_cursor > 0 then
        close cur;
    end if;
    return ret;
end;
/

