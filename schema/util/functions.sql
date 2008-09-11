-- This fucntion returns the ordered list of index fields as a string
--
-- $Id$

create or replace function
get_index_fields_list(idx_name varchar2)
return VARCHAR2
is
    cursor icursor(iname varchar2) is 
        select column_name 
        from user_ind_columns
	where lower(index_name) = lower(iname)
        order by column_position; 
    cursor tcursor(iname varchar2) is 
        select table_name, uniqueness 
        from user_indexes
	where lower(index_name) = lower(iname);
    result	varchar2(4000);
    tmp		varchar2(100);
    unqflag	varchar2(100);
begin 
    result := NULL;
    open icursor(idx_name); 
    loop 
        fetch icursor into tmp;
        exit when icursor%NOTFOUND; 
	if result is NULL then 
	    result := lower(tmp);
        else
	    result := result || ', ' || lower(tmp);
	end if;
    end loop; 
    close icursor;
    open tcursor(idx_name);
    fetch tcursor into tmp, unqflag;
    if tcursor%NOTFOUND then
        close tcursor;
        return 'NO-TABLE(' || result || ')';
    end if;
    close tcursor;
    return lower(unqflag) || ' ' || lower(tmp) || '(' || result || ')';
end;
/
show errors

create or replace function
get_obj_deps_list(obj_name VARCHAR2)
return VARCHAR2
is
    cursor dcursor(oname VARCHAR2) is 
        select referenced_type || '(' || referenced_name || ')'
        from user_dependencies
	where lower(name) = lower(oname)
	order by referenced_NAME,referenced_type;
    result	VARCHAR2(4000);
    tmp		VARCHAR2(1000);
begin 
    result := NULL;
    open dcursor(obj_name); 
    loop 
        fetch dcursor into tmp;
        exit when dcursor%NOTFOUND; 
	if result is NULL then 
	    result := lower(tmp);
        else
	    result := result || ', ' || lower(tmp);
	end if;
    end loop; 
    close dcursor;
    return result;
end;
/
show errors


create or replace function
get_table_fields_list(tab_name varchar2)
return VARCHAR2
is
    cursor tcursor(tname varchar2) is 
        select column_name 
        from user_tab_columns
	where lower(table_name) = lower(tname)
        order by column_name; 
    result	varchar2(4000);
    tmp		varchar2(100);
begin 
    result := NULL;
    open tcursor(tab_name); 
    loop 
        fetch tcursor into tmp;
        exit when tcursor%NOTFOUND; 
	if result is NULL then 
	    result := lower(tmp);
        else
	    result := result || ', ' || lower(tmp);
	end if;
    end loop; 
    close tcursor;
    return '(' || result || ')';
end;
/
show errors

-- $Log$
-- Revision 1.2  2001/10/22 22:03:47  pjones
-- different ordering
--
-- Revision 1.1  2001/07/01 09:35:08  gafton
-- schema extracting tool updated
--
