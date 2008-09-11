DECLARE
    cursor icursor is 
        select index_name, table_name, column_name 
        from user_ind_columns 
        order by table_name, index_name, column_position; 
    oiname	VARCHAR2(100);
    iname	VARCHAR2(100); 
    otname	VARCHAR2(100);
    tname	VARCHAR2(100); 
    cname	VARCHAR2(100); 
    result	VARCHAR2(4000); 
BEGIN 
    result := ''; 
    oiname := ''; 
    otname := ''; 
    open icursor; 
    dbms_output.enable(100000);
    dbms_output.put_line('Available Indexes:');
    LOOP 
        fetch icursor into iname, tname, cname; 
	-- dbms_output.put_line(iname || ' : ' ||  tname || ' : ' || cname);
        exit when icursor%NOTFOUND; 
        if iname = oiname then 
	   -- dbms_output.put_line('Result is now: ' || result);
	    result := result || ', ' || cname;
        else 
            if result is not NULL then 
                dbms_output.put_line('Index ' || oiname || ' on ' || 
		    otname || ' (' || result || ')'); 
            end if; 
            oiname := iname; 
            otname := tname; 
            result := cname;
        end if; 
    end loop; 
    dbms_output.put_line('End of List.');
    close icursor; 
END;
/
